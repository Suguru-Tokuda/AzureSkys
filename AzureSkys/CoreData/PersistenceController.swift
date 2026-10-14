//
//  PersistenceController.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/5/23.
//

import CoreData
import Combine

@MainActor
final class PersistenceController: ObservableObject {
    private enum Constants {
        static let containerName = "WeatherCoreData"
    }

    static let shared = PersistenceController()
    static let preview = PersistenceController(inMemory: true)

    static let cloudContainerIdentifier = "iCloud.com.stokuda.weather"

    @Published private(set) var viewContext: NSManagedObjectContext
    @Published private(set) var isReconfiguring = false
    @Published private(set) var accountChangeError: Error?
    private(set) var container: NSPersistentCloudKitContainer
    private(set) var syncEnabled: Bool
    private let inMemory: Bool
    private var subscriptions: Set<AnyCancellable> = []
    private var operationActive = false
    private var operationWaiters: [CheckedContinuation<Void, Never>] = []

    init(
        inMemory: Bool = false,
        syncEnabled: Bool = false,
        storeURL: URL? = nil
    ) {
        self.inMemory = inMemory
        self.syncEnabled = syncEnabled && !inMemory

        do {
            container = try Self.makeContainer(url: storeURL, inMemory: inMemory, syncEnabled: self.syncEnabled)
            viewContext = container.viewContext
            try Self.load(container)

        } catch {
            fatalError("Unable to load saved locations: \(error)")
        }

        observeSyncEvents()
    }

    func reportSyncError(_ error: Error?) {
        accountChangeError = error
    }

    func setSyncEnabled(_ enabled: Bool) async throws {
        try await reloadStore(syncEnabled: enabled, force: false)
    }

    func reloadStore(syncEnabled enabled: Bool, force: Bool = true) async throws {
        await acquireOperation()

        defer { releaseOperation() }

        guard !inMemory, force || syncEnabled != enabled else { return }

        isReconfiguring = true

        defer { isReconfiguring = false }

        if viewContext.hasChanges {
            try viewContext.save()
        }

        let previous = container

        guard let description = previous.persistentStoreDescriptions.first else {
            throw PersistenceError.missingStoreDescription
        }

        guard let url = description.url else {
            throw PersistenceError.missingStoreURL
        }

        let replacement = try Self.makeContainer(url: url, inMemory: false, syncEnabled: enabled)

        viewContext.reset()

        for store in previous.persistentStoreCoordinator.persistentStores {
            try previous.persistentStoreCoordinator.remove(store)
        }

        do {
            try Self.load(replacement)
        } catch {
            // Restore the previous configuration if opening the replacement fails.
            try Self.load(previous)
            accountChangeError = error
            throw error
        }

        container = replacement
        viewContext = replacement.viewContext
        syncEnabled = enabled
        accountChangeError = nil
        observeSyncEvents()
    }

    func performBackgroundTask<T>(_ operation: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await performBackgroundTask { context, _ in try operation(context) }
    }

    func performBackgroundTask<T>(
        _ operation: @escaping (NSManagedObjectContext, NSPersistentCloudKitContainer) throws -> T
    ) async throws -> T {
        await acquireOperation()
        defer { releaseOperation() }

        try Task.checkCancellation()
        let activeContainer = container
        return try await activeContainer.performBackgroundTask { context in
            try operation(context, activeContainer)
        }
    }

    func performLocationChange(_ operation: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        try await performBackgroundTask { context in
            try operation(context)
            if context.hasChanges { try context.save() }
        }
    }

    private func observeSyncEvents() {
        subscriptions.removeAll()
        NotificationCenter.default.publisher(
            for: NSPersistentCloudKitContainer.eventChangedNotification,
            object: container
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] notification in
            guard let self else { return }

            guard
                let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                    as? NSPersistentCloudKitContainer.Event, event.endDate != nil
            else { return }
            accountChangeError = event.error

        }
        .store(in: &subscriptions)
    }

    private static func cloudOptions() -> NSPersistentCloudKitContainerOptions {
        NSPersistentCloudKitContainerOptions(containerIdentifier: cloudContainerIdentifier)
    }

    private static func makeContainer(url: URL?, inMemory: Bool, syncEnabled: Bool) throws
        -> NSPersistentCloudKitContainer
    {
        let container = NSPersistentCloudKitContainer(name: Constants.containerName)

        guard let description = container.persistentStoreDescriptions.first else {
            throw PersistenceError.missingStoreDescription
        }

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else if let url {
            description.url = url
        }

        description.shouldAddStoreAsynchronously = false
        description.cloudKitContainerOptions = syncEnabled && !inMemory ? cloudOptions() : nil
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }

    private static func load(_ container: NSPersistentContainer) throws {
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if let loadError { throw loadError }
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
