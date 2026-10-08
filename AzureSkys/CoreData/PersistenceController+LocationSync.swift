//
//  PersistenceController+LocationSync.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/7/26.
//

import CoreData
import CloudKit

struct PendingLocationChange: Equatable {
    let id: String
    let action: String
    let revision: String
}

extension PersistenceController {
    func pendingLocationChanges() async throws -> [PendingLocationChange] {
        try await performBackgroundTask { context in
            let rows = try context.fetch(NSFetchRequest<NSManagedObject>(entityName: "LocalSyncAction"))
            let changes = rows.compactMap { row -> PendingLocationChange? in
                guard let id = row.value(forKey: "id") as? String,
                    let action = row.value(forKey: "action") as? String
                else { return nil }
                let storedRevision = row.value(forKey: "revision") as? String
                let revision = storedRevision ?? UUID().uuidString
                if storedRevision == nil { row.setValue(revision, forKey: "revision") }
                return PendingLocationChange(id: id, action: action, revision: revision)
            }
            if context.hasChanges { try context.save() }
            return changes
        }
    }

    func recordForSync(_ id: String) async throws -> CKRecord? {
        try await performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            guard let entity = try context.fetch(request).first, let place = SavedPlace(from: entity) else {
                return nil
            }
            let state = try Self.recordState(id, in: context)
            return try LocationCloudRecord.make(place, systemFields: state?.value(forKey: "data") as? Data)
        }
    }

    func applyRemoteLocations(_ records: [CKRecord], deletedIDs: [CKRecord.ID]) async throws {
        // Decode before changing any local objects: malformed batches must not partially commit.
        let places = try records.map { try LocationCloudRecord.place(from: $0) }
        try await performBackgroundTask { context in
            let actions = try context.fetch(NSFetchRequest<NSManagedObject>(entityName: "LocalSyncAction"))
            let pendingIDs = Set(actions.compactMap { $0.value(forKey: "id") as? String })
            for (place, record) in zip(places, records) {
                try Self.cacheRecord(record, in: context)
                if !pendingIDs.contains(place.id) { try Self.upsert(place, in: context) }
            }
            for recordID in deletedIDs where recordID.zoneID == LocationCloudRecord.zoneID {
                if let state = try Self.recordState(recordID.recordName, in: context) { context.delete(state) }
                if !pendingIDs.contains(recordID.recordName) { try Self.delete(recordID.recordName, in: context) }
            }
            if context.hasChanges { try context.save() }
        }
    }

    func acknowledgeLocationChanges(saved: [CKRecord], deleted: [CKRecord.ID], sent: [String: PendingLocationChange])
        async throws
    {
        try await performBackgroundTask { context in
            for record in saved { try Self.cacheRecord(record, in: context) }
            for id in deleted {
                if let state = try Self.recordState(id.recordName, in: context) { context.delete(state) }
            }
            let request = NSFetchRequest<NSManagedObject>(entityName: "LocalSyncAction")
            for row in try context.fetch(request) {
                guard let id = row.value(forKey: "id") as? String, let change = sent[id],
                    change.revision == row.value(forKey: "revision") as? String
                else { continue }
                let savedOK = change.action == "upsert" && saved.contains { $0.recordID.recordName == id }
                let deletedOK = change.action == "delete" && deleted.contains { $0.recordName == id }
                if savedOK || deletedOK { context.delete(row) }
            }
            if context.hasChanges { try context.save() }
        }
    }

    func cacheServerRecord(_ record: CKRecord) async throws {
        try await performBackgroundTask { context in
            try Self.cacheRecord(record, in: context)
            try context.save()
        }
    }

    func clearServerRecord(_ id: String) async throws {
        try await performBackgroundTask { context in
            if let state = try Self.recordState(id, in: context) { context.delete(state) }
            if context.hasChanges { try context.save() }
        }
    }

    func queueAllLocations(clearServerRecords: Bool = false) async throws {
        try await performBackgroundTask { context in
            if clearServerRecords {
                for state in try context.fetch(NSFetchRequest<NSManagedObject>(entityName: "LocalCloudRecord")) {
                    context.delete(state)
                }
            }
            let actions = try context.fetch(NSFetchRequest<NSManagedObject>(entityName: "LocalSyncAction"))
            let pendingIDs = Set(actions.compactMap { $0.value(forKey: "id") as? String })
            for place in try context.fetch(PlaceEntity.fetchRequest()) {
                if let id = place.id, !pendingIDs.contains(id) {
                    try Self.markPending(id, action: "upsert", in: context)
                }
            }
            if context.hasChanges { try context.save() }
        }
    }

    func importLegacyCloudLocations(_ places: [SavedPlace]) async throws {
        try await performBackgroundTask { context in
            let actions = try context.fetch(NSFetchRequest<NSManagedObject>(entityName: "LocalSyncAction"))
            let pendingIDs = Set(actions.compactMap { $0.value(forKey: "id") as? String })
            var existingIDs = Set(try context.fetch(PlaceEntity.fetchRequest()).compactMap(\.id))
            for place in places where !pendingIDs.contains(place.id) && !existingIDs.contains(place.id) {
                try Self.upsert(place, in: context)
                try Self.markPending(place.id, action: "upsert", in: context)
                existingIDs.insert(place.id)
            }
            if context.hasChanges { try context.save() }
        }
    }

    // Identity is retained on sign-out. Another account cannot silently inherit these records.
    func bindSyncAccount(_ accountID: String) throws {
        if let data = try metadata("syncAccount"), let existing = String(data: data, encoding: .utf8),
            existing != accountID
        {
            throw LocationSyncError.differentAccount
        }
        try setMetadata("syncAccount", data: Data(accountID.utf8))
    }

    private static func recordState(_ id: String, in context: NSManagedObjectContext) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LocalCloudRecord")
        request.predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(request).first
    }

    private static func cacheRecord(_ record: CKRecord, in context: NSManagedObjectContext) throws {
        guard record.recordType == LocationCloudRecord.recordType, record.recordID.zoneID == LocationCloudRecord.zoneID
        else {
            throw LocationSyncError.invalidRecord
        }
        let state =
            try recordState(record.recordID.recordName, in: context)
            ?? NSEntityDescription.insertNewObject(forEntityName: "LocalCloudRecord", into: context)
        state.setValue(record.recordID.recordName, forKey: "id")
        state.setValue(LocationCloudRecord.systemFields(of: record), forKey: "data")
    }
}
