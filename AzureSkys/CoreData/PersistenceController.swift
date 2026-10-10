//
//  PersistenceController.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/5/23.
//

import CoreData
import Combine
import CloudKit
import UIKit

@MainActor
final class PersistenceController: ObservableObject {
    private enum Constants {
        static let weatherCoreData = "WeatherCoreData"
        static let weatherLocalCoreData = "WeatherLocalCoreData"
        static let localStoreExtension = "local.sqlite"
        static let legacyMigration = "legacyMigration"
    }

    static let shared = PersistenceController()
    static let preview = PersistenceController(inMemory: true)

    @Published private(set) var viewContext: NSManagedObjectContext
    @Published private(set) var isReconfiguring = false
    @Published private(set) var accountChangeError: Error?
    @Published var pendingUploadCount = 0
    private(set) var container: NSPersistentContainer
    private(set) var syncEnabled = false
    private let inMemory: Bool
    private var requestedSyncEnabled: Bool
    private var syncCoordinator: (any LocationSyncControlling)?
    private var subscriptions: Set<AnyCancellable> = []
    private var operationActive = false
    private var operationWaiters: [CheckedContinuation<Void, Never>] = []

    init(
        inMemory: Bool = false,
        syncEnabled: Bool = false,
        storeURL: URL? = nil,
        syncCoordinatorFactory: ((PersistenceController) -> any LocationSyncControlling)? = nil
    ) {
        self.inMemory = inMemory
        requestedSyncEnabled = syncEnabled

        let legacyTemplate = NSPersistentContainer(name: Constants.weatherCoreData)
        let legacyURL = storeURL ?? legacyTemplate.persistentStoreDescriptions[0].url!
        let localURL = legacyURL.deletingPathExtension().appendingPathExtension(Constants.localStoreExtension)

        container = Self.makeLocalContainer(url: localURL, inMemory: inMemory)
        viewContext = container.viewContext
        Self.loadSynchronously(container)

        do {
            if !inMemory, try metadata(Constants.legacyMigration) == nil {
                if FileManager.default.fileExists(atPath: legacyURL.path) {
                    // Migration reads the old SQLite store without starting a CloudKit delegate.
                    legacyTemplate.persistentStoreDescriptions[0].url = legacyURL
                    Self.configure(legacyTemplate, url: legacyURL, inMemory: false)
                    Self.loadSynchronously(legacyTemplate)

                    let places = try legacyTemplate.viewContext.fetch(PlaceEntity.fetchRequest()).compactMap {
                        SavedPlace(from: $0)
                    }

                    for place in places {
                        try Self.upsert(place, in: viewContext)
                        try Self.markPending(place.id, action: "upsert", in: viewContext)
                    }

                    try viewContext.save()

                    for store in legacyTemplate.persistentStoreCoordinator.persistentStores {
                        try legacyTemplate.persistentStoreCoordinator.remove(store)
                    }
                }

                try setMetadata(Constants.legacyMigration, data: Data([1]))
            }
        } catch {
            fatalError("Unable to migrate saved locations: \(error)")
        }

        if let syncCoordinatorFactory {
            syncCoordinator = syncCoordinatorFactory(self)
        } else if !inMemory {
            syncCoordinator = CloudKitLocationSync(persistence: self)
        }

        if !inMemory || syncCoordinatorFactory != nil {
            for name in [Notification.Name.CKAccountChanged, UIApplication.didBecomeActiveNotification] {
                NotificationCenter.default.publisher(for: name)
                    .sink { [weak self] _ in
                        Task {
                            @MainActor [weak self] in await self?.refreshSync()
                        }
                    }.store(in: &subscriptions)
            }

            Task {
                [weak self] in await self?.refreshSync()
            }
        }
    }

    func setSyncEnabled(_ enabled: Bool) async throws {
        let previousRequest = requestedSyncEnabled

        requestedSyncEnabled = enabled

        if enabled {
            do {
                accountChangeError = nil
                try await syncCoordinator?.start()
                syncEnabled = syncCoordinator?.isRunning ?? false
            } catch {
                requestedSyncEnabled = previousRequest
                await syncCoordinator?.stop()
                accountChangeError = error
                syncEnabled = false

                throw error
            }
        } else {
            await syncCoordinator?.stop()
            syncEnabled = false
        }
    }

    private func refreshSync() async {
        guard requestedSyncEnabled else { return }

        do {
            accountChangeError = nil
            try await syncCoordinator?.start()
            syncEnabled = syncCoordinator?.isRunning ?? false
        } catch {
            accountChangeError = error
            syncEnabled = false
        }
    }

    func reportSyncError(_ error: Error?) {
        accountChangeError = error
        syncEnabled = syncCoordinator?.isRunning ?? false
    }

    // Retained for explicit persistence recovery/testing; sync toggles do not reload local data.
    func reloadStore(syncEnabled enabled: Bool, force: Bool = true) async throws {
        try await setSyncEnabled(enabled)

        guard force, !inMemory else { return }

        await acquireOperation()

        defer {
            releaseOperation()
        }

        isReconfiguring = true

        defer {
            isReconfiguring = false
        }

        if viewContext.hasChanges {
            try viewContext.save()
        }

        let url = container.persistentStoreDescriptions[0].url!

        viewContext.reset()

        for store in container.persistentStoreCoordinator.persistentStores {
            try container.persistentStoreCoordinator.remove(store)
        }

        let replacement = Self.makeLocalContainer(url: url, inMemory: false)

        Self.loadSynchronously(replacement)
        container = replacement
        viewContext = replacement.viewContext
    }

    func performBackgroundTask<T>(_ operation: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        await acquireOperation()

        defer {
            releaseOperation()
        }

        try Task.checkCancellation()

        return try await container.performBackgroundTask(operation)
    }

    func performLocationChange(_ operation: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        try await performBackgroundTask { context in
            try operation(context)

            for entity in context.insertedObjects.union(context.updatedObjects) {
                if let place = entity as? PlaceEntity, let id = place.id {
                    try Self.markPending(id, action: "upsert", in: context)
                }
            }

            for entity in context.deletedObjects {
                if let place = entity as? PlaceEntity, let id = place.id {
                    try Self.markPending(id, action: "delete", in: context)
                }
            }

            if context.hasChanges {
                try context.save()
            }
        }

        // Local saves finish before networking. The journal survives failures or process termination.

        if requestedSyncEnabled {
            Task { [weak self] in
                guard let self else { return }

                do {
                    try await self.syncCoordinator?.enqueueLocalChanges()
                } catch {
                    self.reportSyncError(error)
                }
            }
        }
    }

    func metadata(_ key: String) throws -> Data? {
        let context = container.newBackgroundContext()

        return try context.performAndWait {
            let request = NSFetchRequest<NSManagedObject>(entityName: "LocalSyncMetadata")

            request.predicate = NSPredicate(format: "key == %@", key)

            return try context.fetch(request).first?.value(forKey: "data") as? Data
        }
    }

    func setMetadata(_ key: String, data: Data?) throws {
        let context = container.newBackgroundContext()

        try context.performAndWait {
            let request = NSFetchRequest<NSManagedObject>(entityName: "LocalSyncMetadata")

            request.predicate = NSPredicate(format: "key == %@", key)

            let row =
                try context.fetch(request).first
                ?? NSEntityDescription.insertNewObject(forEntityName: "LocalSyncMetadata", into: context)
            row.setValue(key, forKey: "key")
            row.setValue(data, forKey: "data")
            try context.save()
        }
    }

    static func markPending(_ id: String, action: String, in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LocalSyncAction")

        request.predicate = NSPredicate(format: "id == %@", id)

        let row =
            try context.fetch(request).first
            ?? NSEntityDescription.insertNewObject(forEntityName: "LocalSyncAction", into: context)
        row.setValue(id, forKey: "id")
        row.setValue(action, forKey: "action")
        row.setValue(UUID().uuidString, forKey: "revision")
    }

    static func upsert(_ place: SavedPlace, in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()

        request.predicate = NSPredicate(format: "id == %@", place.id)

        let matches = try context.fetch(request)
        let entity =
            matches.first
            ?? PlaceEntity(
                entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                insertInto: context
            )
        for duplicate in matches.dropFirst() {
            context.delete(duplicate)
        }

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

    static func delete(_ id: String, in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()

        request.predicate = NSPredicate(format: "id == %@", id)

        for entity in try context.fetch(request) {
            context.delete(entity)
        }
    }

    private static func makeLocalContainer(url: URL, inMemory: Bool) -> NSPersistentContainer {
        let local = NSPersistentContainer(name: Constants.weatherLocalCoreData)

        configure(local, url: url, inMemory: inMemory)

        return local
    }

    private static func configure(_ container: NSPersistentContainer, url: URL, inMemory: Bool) {
        let description = container.persistentStoreDescriptions[0]

        description.url = inMemory ? URL(fileURLWithPath: "/dev/null") : url
        description.shouldAddStoreAsynchronously = false
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static func loadSynchronously(_ container: NSPersistentContainer) {
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load location store: \(error)")
            }
        }
    }

    private func acquireOperation() async {
        if !operationActive {
            operationActive = true

            return
        }

        await withCheckedContinuation { operationWaiters.append($0) }
    }

    private func releaseOperation() {
        if operationWaiters.isEmpty {
            operationActive = false
        } else {
            operationWaiters.removeFirst().resume()
        }
    }
}
