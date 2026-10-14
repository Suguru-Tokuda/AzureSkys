//
//  PlaceCoreDataManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import CoreData
import CloudKit
import Combine

protocol PlaceCoreDataActions {
    func savePlaceIntoDatabase(place: SavedPlace) async throws
    func getPlaceFromDatabase(id: String) async throws -> SavedPlace?
    func getPlacesFromDatabase() async throws -> [SavedPlace]
    func deleteFromDatabase(place: SavedPlace) async throws
    func clearAllFromDatabase() async throws
}

@MainActor
class PlaceCoreDataManager: PlaceCoreDataActions {
    private let persistence: PersistenceController
    private var syncSubscription: AnyCancellable?

    init(persistence: PersistenceController) {
        self.persistence = persistence
        do {
            try Self.prepareStore(persistence.container)
        } catch {
            fatalError("Unable to prepare saved locations: \(error)")
        }
        observeSyncEvents()
    }

    private func observeSyncEvents() {
        // Observe all containers and compare against the current stack so this remains
        // attached when the user toggles sync and the controller replaces its container.
        syncSubscription = NotificationCenter.default.publisher(
            for: NSPersistentCloudKitContainer.eventChangedNotification
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] notification in
            guard let self,
                let source = notification.object as? NSPersistentCloudKitContainer,
                source === self.persistence.container,
                let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                    as? NSPersistentCloudKitContainer.Event,
                event.endDate != nil, event.succeeded,
                event.type == .import || event.type == .export
            else { return }

            Task { [weak self] in
                guard let self else { return }
                do {
                    try await self.reconcileDuplicates()
                } catch {
                    self.persistence.reportSyncError(error)
                }
            }
        }
    }

    func savePlaceIntoDatabase(place: SavedPlace) async throws {
        try await persistence.performBackgroundTask { context, container in
            try Self.reconcileDuplicates(in: context, container: container)
            try Self.upsert(place, in: context)
            if context.hasChanges { try context.save() }
        }
    }

    func getPlacesFromDatabase() async throws -> [SavedPlace] {
        try await persistence.performBackgroundTask { context, container in
            try Self.reconcileDuplicates(in: context, container: container)
            if context.hasChanges { try context.save() }
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            return try context.fetch(request).compactMap { SavedPlace(from: $0) }
        }
    }

    func getPlaceFromDatabase(id: String) async throws -> SavedPlace? {
        try await persistence.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()

            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1

            return try context.fetch(request).first.flatMap { SavedPlace(from: $0) }
        }
    }

    func deleteFromDatabase(place: SavedPlace) async throws {
        try await persistence.performLocationChange { context in
            try Self.delete(place.id, in: context)
        }
    }

    func clearAllFromDatabase() async throws {
        try await persistence.performLocationChange { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            let records = try context.fetch(request)

            records.forEach { context.delete($0) }
        }
    }

    func reconcileDuplicates() async throws {
        try await persistence.performBackgroundTask { context, container in
            try Self.reconcileDuplicates(in: context, container: container)
            if context.hasChanges { try context.save() }
        }
    }

    nonisolated static func reconcileDuplicates(
        in context: NSManagedObjectContext,
        container: NSPersistentCloudKitContainer
    ) throws {
        try reconcileDuplicates(in: context) { container.recordID(for: $0.objectID)?.recordName }
    }

    nonisolated static func reconcileDuplicates(
        in context: NSManagedObjectContext,
        identity: (PlaceEntity) -> String?
    ) throws {
        var groups: [String: [PlaceEntity]] = [:]
        for place in try context.fetch(PlaceEntity.fetchRequest()) {
            guard let id = place.id else { continue }
            groups[id, default: []].append(place)
        }
        for duplicates in groups.values where duplicates.count > 1 {
            let identified = duplicates.compactMap { entity in
                identity(entity).map { (entity: entity, identity: $0) }
            }
            // Prefer an existing cloud record over a new local row. All devices choose
            // the same survivor when cloud records meet, independent of local object IDs.
            let survivor =
                identified.min { $0.identity < $1.identity }?.entity
                ?? duplicates.min {
                    $0.objectID.uriRepresentation().absoluteString < $1.objectID.uriRepresentation().absoluteString
                }
            for duplicate in duplicates where duplicate !== survivor { context.delete(duplicate) }
        }
    }

    nonisolated static func upsert(_ place: SavedPlace, in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()

        request.predicate = NSPredicate(format: "id == %@", place.id)

        let matches = try context.fetch(request)
        let entity =
            matches.first
            ?? PlaceEntity(
                entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                insertInto: context
            )

        // Avoid generating history and CloudKit exports for unchanged fields.
        let components = try JSONEncoder().encode(place.addressComponents)

        if entity.id != place.id {
            entity.id = place.id
        }

        if entity.name != place.name {
            entity.name = place.name
        }

        if entity.formattedAddress != place.formattedAddress {
            entity.formattedAddress = place.formattedAddress
        }

        if entity.latitude != place.latitude {
            entity.latitude = place.latitude
        }

        if entity.longitude != place.longitude {
            entity.longitude = place.longitude
        }

        if entity.addressComponents != components {
            entity.addressComponents = components
        }
    }

    nonisolated static func delete(_ id: String, in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()

        request.predicate = NSPredicate(format: "id == %@", id)

        for entity in try context.fetch(request) {
            context.delete(entity)
        }
    }
}

extension SavedPlace {
    init?(from entity: PlaceEntity) {
        guard let id = entity.id else { return nil }

        let components =
            entity.addressComponents.flatMap {
                try? JSONDecoder().decode([PlaceAddressComponent].self, from: $0)
            } ?? []
        self.init(
            id: id,
            name: entity.name ?? "",
            formattedAddress: entity.formattedAddress ?? "",
            latitude: entity.latitude,
            longitude: entity.longitude,
            addressComponents: components
        )
    }
}
