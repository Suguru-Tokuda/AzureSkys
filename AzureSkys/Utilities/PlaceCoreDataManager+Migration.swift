import CoreData

extension PlaceCoreDataManager {
    static func prepareStore(_ container: NSPersistentCloudKitContainer) throws {
        try migrateLocalStore(container)
        try reconcileDuplicates(in: container.viewContext, container: container)
        if container.viewContext.hasChanges { try container.viewContext.save() }
    }

    @MainActor
    private static func migrateLocalStore(_ container: NSPersistentCloudKitContainer) throws {
        let viewContext = container.viewContext
        guard let store = container.persistentStoreCoordinator.persistentStores.first,
            let url = store.url
        else { throw PersistenceError.missingStoreURL }

        let migrationKey = "AzureSkysLocalStoreMigration"
        var metadata = container.persistentStoreCoordinator.metadata(for: store)

        guard metadata[migrationKey] == nil else { return }

        let localURL = url.deletingPathExtension().appendingPathExtension("local.sqlite")

        if FileManager.default.fileExists(atPath: localURL.path) {
            let local = NSPersistentContainer(name: "WeatherLocalCoreData")

            guard let description = local.persistentStoreDescriptions.first else {
                throw PersistenceError.missingStoreDescription
            }

            description.url = localURL
            description.shouldAddStoreAsynchronously = false
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

            var loadError: Error?
            local.loadPersistentStores { _, error in loadError = error }
            if let loadError { throw loadError }

            defer {
                for store in local.persistentStoreCoordinator.persistentStores {
                    try? local.persistentStoreCoordinator.remove(store)
                }
            }

            // The newer local store is authoritative, including deletions made while offline.
            let places =
                try local
                .viewContext
                .fetch(PlaceEntity.fetchRequest())
                .compactMap { SavedPlace(from: $0) }

            let ids = Set(places.map(\.id))

            for entity in try viewContext.fetch(PlaceEntity.fetchRequest()) {
                if let id = entity.id, !ids.contains(id) { viewContext.delete(entity) }
            }

            for place in places {
                try PlaceCoreDataManager.upsert(place, in: viewContext)
            }

            try viewContext.save()
        }

        metadata[migrationKey] = true
        container.persistentStoreCoordinator.setMetadata(metadata, for: store)
    }

}
