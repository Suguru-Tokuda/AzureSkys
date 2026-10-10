//
//  CloudKitLocationSync.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/7/26.
//

import CloudKit
import Foundation

@MainActor
protocol LocationSyncControlling: AnyObject {
    var isRunning: Bool { get }
    func start() async throws
    func stop() async
    func enqueueLocalChanges() async throws
}

@MainActor
final class CloudKitLocationSync: CKSyncEngineDelegate, LocationSyncControlling {
    private weak var persistence: PersistenceController?
    private let cloud: CKContainer
    private var engine: CKSyncEngine?
    private var starting = false
    private var restartRequested = false
    private var generation = 0
    private var activationRetry: Task<Void, Never>?
    private var uploadTask: Task<Void, Never>?
    private var inFlight: [String: PendingLocationChange] = [:]
    var isRunning: Bool { engine != nil }

    init(persistence: PersistenceController, cloud: CKContainer = CKContainer(identifier: "iCloud.com.stokuda.weather"))
    {
        self.persistence = persistence
        self.cloud = cloud
    }

    func start() async throws {
        guard let persistence else { return }
        if starting {
            restartRequested = true
            return
        }
        starting = true
        defer {
            starting = false
            if restartRequested {
                restartRequested = false
                Task { [weak self] in
                    do { try await self?.start() } catch { self?.persistence?.reportSyncError(error) }
                }
            }
        }
        let currentGeneration = generation
        do {
            guard try await cloud.accountStatus() == .available else {
                await stop()
                return
            }
            let identity = try await cloud.userRecordID().recordName
            guard currentGeneration == generation else { return }
            do { try persistence.bindSyncAccount(identity) } catch {
                await stop()
                throw error
            }
            if engine != nil {
                try await enqueueLocalChanges()
                return
            }

            if try persistence.metadata("legacyCloudMigration") == nil {
                let legacy = try await fetchLegacyLocations()
                // Never import data fetched before an intervening account change or disable action.
                let latestIdentity = try await cloud.userRecordID().recordName
                guard currentGeneration == generation else { return }
                guard latestIdentity == identity else { throw LocationSyncError.differentAccount }
                try await persistence.importLegacyCloudLocations(legacy)
                guard currentGeneration == generation else { return }
                try persistence.setMetadata("legacyCloudMigration", data: Data([1]))
            }
            if try persistence.metadata("ckSyncBootstrap") == nil {
                try await persistence.queueAllLocations()
                try persistence.setMetadata("ckSyncBootstrap", data: Data([1]))
            }
            guard currentGeneration == generation else { return }
            let state = try persistence.metadata("ckSyncState").map {
                try JSONDecoder().decode(CKSyncEngine.State.Serialization.self, from: $0)
            }
            let syncEngine = CKSyncEngine(
                .init(database: cloud.privateCloudDatabase, stateSerialization: state, delegate: self))
            engine = syncEngine
            syncEngine.state.add(pendingDatabaseChanges: [.saveZone(CKRecordZone(zoneID: LocationCloudRecord.zoneID))])
            try await enqueueLocalChanges()
            // Restore immediately on activation rather than waiting for the
            // automatic scheduler to fetch a new installation's empty store.
            persistence.reportSyncError(nil)
            do {
                try await syncEngine.fetchChanges()
            } catch {
                // Keep the engine active so its automatic retries can recover offline.
                persistence.reportSyncError(error)
            }
        } catch {
            if currentGeneration == generation { scheduleActivationRetry(error) }
            throw error
        }
    }

    func stop() async {
        activationRetry?.cancel()
        activationRetry = nil
        restartRequested = false
        generation += 1
        uploadTask?.cancel()
        uploadTask = nil
        let previous = engine
        engine = nil
        inFlight.removeAll()
        await previous?.cancelOperations()
    }

    func enqueueLocalChanges() async throws {
        try await enqueueLocalChanges(retrying: [])
        requestUpload()
    }

    private func requestUpload() {
        guard uploadTask == nil, let engine,
            !engine.state.pendingRecordZoneChanges.isEmpty || !engine.state.pendingDatabaseChanges.isEmpty
        else { return }
        uploadTask = Task { [weak self] in
            guard let self else { return }
            defer {
                if self.engine === engine { self.uploadTask = nil }
            }
            do {
                try await engine.sendChanges()
            } catch {
                if self.engine === engine { self.persistence?.reportSyncError(error) }
            }
        }
    }

    private func enqueueLocalChanges(retrying: Set<String>) async throws {
        guard let engine, let persistence else { return }
        let changes = try await persistence.pendingLocationChanges()
        guard self.engine === engine else { return }
        // Replace the opposite action after a local re-add/delete, while leaving
        // unchanged pending operations in place so the engine can manage retry scheduling.
        let queued = Set(engine.state.pendingRecordZoneChanges)
        var additions: [CKSyncEngine.PendingRecordZoneChange] = []
        let journalIDs = Set(changes.map(\.id))
        // An acknowledgement can commit before the engine's next state checkpoint.
        // Remove stale serialized pending changes on recovery, using the durable journal.
        var removals = Array(queued).filter { change in
            switch change {
            case .saveRecord(let id), .deleteRecord(let id):
                id.zoneID == LocationCloudRecord.zoneID && !journalIDs.contains(id.recordName)
            @unknown default: false
            }
        }
        for change in changes {
            let id = LocationCloudRecord.recordID(change.id)
            let desired: CKSyncEngine.PendingRecordZoneChange =
                change.action == "delete" ? .deleteRecord(id) : .saveRecord(id)
            let opposite: CKSyncEngine.PendingRecordZoneChange =
                change.action == "delete" ? .saveRecord(id) : .deleteRecord(id)
            if queued.contains(opposite) { removals.append(opposite) }
            if !queued.contains(desired) || retrying.contains(change.id) { additions.append(desired) }
        }
        if !removals.isEmpty { engine.state.remove(pendingRecordZoneChanges: removals) }
        if !additions.isEmpty { engine.state.add(pendingRecordZoneChanges: additions) }
    }

    // The engine requests bounded batches. Revision IDs ensure a late acknowledgement
    // cannot clear an edit made while the previous version was being uploaded.
    func prepareBatch(_ changes: [PendingLocationChange]) async throws -> CKSyncEngine.RecordZoneChangeBatch? {
        guard let persistence, !changes.isEmpty else { return nil }
        var records: [CKRecord] = []
        var deletions: [CKRecord.ID] = []
        for change in changes.prefix(250) {
            if change.action == "delete" {
                deletions.append(LocationCloudRecord.recordID(change.id))
            } else if let record = try await persistence.recordForSync(change.id) {
                records.append(record)
            } else {
                // An intervening local deletion will be represented by a newer journal revision.
                continue
            }
            inFlight[change.id] = change
        }
        guard !records.isEmpty || !deletions.isEmpty else { return nil }
        return .init(recordsToSave: records, recordIDsToDelete: deletions)
    }

    func nextRecordZoneChangeBatch(_ context: CKSyncEngine.SendChangesContext, syncEngine: CKSyncEngine) async
        -> CKSyncEngine.RecordZoneChangeBatch?
    {
        guard engine === syncEngine, let persistence else { return nil }
        do {
            let changes = try await persistence.pendingLocationChanges().filter {
                context.options.scope.contains(LocationCloudRecord.recordID($0.id))
            }
            return try await prepareBatch(changes)
        } catch {
            persistence.reportSyncError(error)
            return nil
        }
    }

    func nextFetchChangesOptions(_ context: CKSyncEngine.FetchChangesContext, syncEngine: CKSyncEngine) async
        -> CKSyncEngine.FetchChangesOptions
    {
        // Core Data's old zone is read only during one-time migration.
        .init(scope: .zoneIDs([LocationCloudRecord.zoneID]))
    }

    func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        guard engine === syncEngine, let persistence else { return }
        do {
            switch event {
            case .stateUpdate(let update):
                try persistence.setMetadata("ckSyncState", data: JSONEncoder().encode(update.stateSerialization))
            case .accountChange(let change):
                // Keep local locations and journal entries intact on sign-out or account switch.
                switch change.changeType {
                case .signOut:
                    invalidate(syncEngine)
                    persistence.reportSyncError(nil)
                case .switchAccounts:
                    try persistence.setMetadata("ckSyncState", data: nil)
                    invalidate(syncEngine)
                    persistence.reportSyncError(LocationSyncError.differentAccount)
                case .signIn(let user):
                    try persistence.bindSyncAccount(user.recordName)
                    try await enqueueLocalChanges()
                @unknown default: break
                }
            case .fetchedRecordZoneChanges(let changes):
                let records = changes.modifications.map(\.record).filter {
                    $0.recordID.zoneID == LocationCloudRecord.zoneID
                }
                let deleted = changes.deletions.map(\.recordID).filter { $0.zoneID == LocationCloudRecord.zoneID }
                try await persistence.applyRemoteLocations(records, deletedIDs: deleted)
                try await enqueueLocalChanges()
            case .sentRecordZoneChanges(let changes):
                persistence.reportSyncError(nil)
                var retryIDs: Set<String> = []
                try await persistence.acknowledgeLocationChanges(
                    saved: changes.savedRecords, deleted: changes.deletedRecordIDs, sent: inFlight)
                for record in changes.savedRecords { inFlight.removeValue(forKey: record.recordID.recordName) }
                for id in changes.deletedRecordIDs { inFlight.removeValue(forKey: id.recordName) }
                for failure in changes.failedRecordSaves {
                    switch failure.error.code {
                    case .serverRecordChanged:
                        if let server = failure.error.serverRecord {
                            try await persistence.cacheServerRecord(server)
                            retryIDs.insert(failure.record.recordID.recordName)
                        } else {
                            persistence.reportSyncError(failure.error)
                        }
                    case .unknownItem:
                        try await persistence.clearServerRecord(failure.record.recordID.recordName)
                        retryIDs.insert(failure.record.recordID.recordName)
                    case .zoneNotFound:
                        try await recreateZone(syncEngine)
                    default: persistence.reportSyncError(failure.error)
                    }
                }
                for (id, error) in changes.failedRecordDeletes {
                    if error.code == .unknownItem {
                        // The server already deleted this record; acknowledge the matching revision.
                        try await persistence.acknowledgeLocationChanges(saved: [], deleted: [id], sent: inFlight)
                        inFlight.removeValue(forKey: id.recordName)
                    } else if error.code == .zoneNotFound {
                        try await recreateZone(syncEngine)
                    } else {
                        persistence.reportSyncError(error)
                    }
                }
                try await enqueueLocalChanges(retrying: retryIDs)
            case .fetchedDatabaseChanges(let changes):
                if changes.deletions.contains(where: { $0.zoneID == LocationCloudRecord.zoneID }) {
                    try await recreateZone(syncEngine)
                }
            case .sentDatabaseChanges(let changes):
                if let failure = changes.failedZoneSaves.first { persistence.reportSyncError(failure.error) }
            case .didFetchRecordZoneChanges(let changes):
                if let error = changes.error { persistence.reportSyncError(error) }
            default: break
            }
        } catch {
            // Do not checkpoint past remote changes that failed to commit locally.
            // Discard the cursor so the next activation can fetch the full zone again.
            try? persistence.setMetadata("ckSyncState", data: nil)
            invalidate(syncEngine)
            persistence.reportSyncError(error)
        }
    }

    // Before the engine exists, identity lookup or legacy import can fail offline.
    // Retry activation separately; once running, CKSyncEngine owns network retries.
    private func scheduleActivationRetry(_ error: Error) {
        guard let error = error as? CKError,
            [
                .networkFailure, .networkUnavailable, .accountTemporarilyUnavailable,
                .serviceUnavailable, .requestRateLimited, .zoneBusy,
            ].contains(error.code)
        else { return }
        activationRetry?.cancel()
        let delay = max(30, error.userInfo[CKErrorRetryAfterKey] as? Double ?? 30)
        activationRetry = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(delay)) } catch { return }
            guard let self, !Task.isCancelled else { return }
            self.activationRetry = nil
            do { try await self.start() } catch { self.persistence?.reportSyncError(error) }
        }
    }

    private func invalidate(_ syncEngine: CKSyncEngine) {
        activationRetry?.cancel()
        activationRetry = nil
        generation += 1
        uploadTask?.cancel()
        uploadTask = nil
        engine = nil
        inFlight.removeAll()
        // Avoid awaiting cancellation from inside an engine callback.
        Task { await syncEngine.cancelOperations() }
    }

    private func recreateZone(_ syncEngine: CKSyncEngine) async throws {
        guard let persistence else { return }
        try await persistence.queueAllLocations(clearServerRecords: true)
        syncEngine.state.add(pendingDatabaseChanges: [.saveZone(CKRecordZone(zoneID: LocationCloudRecord.zoneID))])
        let ids = Set(try await persistence.pendingLocationChanges().map(\.id))
        try await enqueueLocalChanges(retrying: ids)
    }

    private func fetchLegacyLocations() async throws -> [SavedPlace] {
        var token: CKServerChangeToken?
        var records: [CKRecord.ID: CKRecord] = [:]
        do {
            while true {
                let page = try await cloud.privateCloudDatabase.recordZoneChanges(
                    inZoneWith: LocationCloudRecord.legacyZoneID, since: token)
                for (id, result) in page.modificationResultsByID { records[id] = try result.get().record }
                for deletion in page.deletions { records.removeValue(forKey: deletion.recordID) }
                token = page.changeToken
                if !page.moreComing { break }
            }
        } catch let error as CKError where error.code == .zoneNotFound {
            return []  // New users have no Core Data cloud zone to migrate.
        }
        return try records.values.compactMap { try LocationCloudRecord.legacyPlace(from: $0) }
    }
}
