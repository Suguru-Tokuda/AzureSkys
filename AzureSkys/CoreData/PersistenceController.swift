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
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        return result
    }()
    
    @Published private(set) var viewContext: NSManagedObjectContext
    @Published private(set) var isReconfiguring = false
    private var operationActive = false
    private var operationWaiters: [CheckedContinuation<Void, Never>] = []
    private let inMemory: Bool

    private(set) var container: NSPersistentContainer
    private(set) var syncEnabled: Bool
    
    init(inMemory: Bool = false, syncEnabled: Bool = false, storeURL: URL? = nil) {
        self.inMemory = inMemory
        self.syncEnabled = syncEnabled
        container = NSPersistentCloudKitContainer(
            name: PersistenceControllerConstants.weatherCoreData
        )

        viewContext = container.viewContext

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError(PersistenceControllerConstants.missingPersistentStoreDescription)
        }

        if let storeURL { description.url = storeURL }

        description.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )

        description.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        
        if inMemory || !syncEnabled {
            description.cloudKitContainerOptions = nil
        }
        
        if inMemory {
            description.url = URL(fileURLWithPath: PersistenceControllerConstants.nullDevicePath)
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError(PersistenceControllerConstants.unresolvedError(String(describing: error), String(describing: error.userInfo)))
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func setSyncEnabled(_ enabled: Bool) async throws {
        try await reloadStore(syncEnabled: enabled, force: false)
    }

    // Also used to verify replacement independently of CloudKit availability.
    func reloadStore(syncEnabled enabled: Bool, force: Bool = true) async throws {
        await acquireOperation()
        defer { releaseOperation() }
        try Task.checkCancellation()
        guard force || enabled != syncEnabled else { return }
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            throw PersistenceError.missingStoreURL
        }
        isReconfiguring = true
        defer { isReconfiguring = false }

        let previousContainer = container
        let replacement = try makeContainer(storeURL: storeURL, syncEnabled: enabled)
        try await savePendingChanges()
        do {
            try await unloadCurrentStores()
            try await loadStores(in: replacement)
        } catch {
            // Detach any partially loaded replacement before restoring the old stack.
            for store in replacement.persistentStoreCoordinator.persistentStores {
                try replacement.persistentStoreCoordinator.remove(store)
            }
            for store in previousContainer.persistentStoreCoordinator.persistentStores {
                try previousContainer.persistentStoreCoordinator.remove(store)
            }
            try await loadStores(in: previousContainer)
            viewContext = previousContainer.viewContext
            throw error
        }
        container = replacement
        viewContext = replacement.viewContext
        syncEnabled = enabled
    }

    func performBackgroundTask<T>(
        _ operation: @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        await acquireOperation()
        defer { releaseOperation() }
        try Task.checkCancellation()
        return try await container.performBackgroundTask(operation)
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

    private func savePendingChanges() async throws {
        let context = container.viewContext

        try await context.perform {
            guard context.hasChanges else { return }
            try context.save()
        }
    }

    private func unloadCurrentStores() async throws {
        let context = container.viewContext
        let coordinator = container.persistentStoreCoordinator

        try await context.perform {
            context.reset()

            for store in coordinator.persistentStores {
                try coordinator.remove(store)
            }
        }
    }

    private func makeContainer(
        storeURL: URL,
        syncEnabled: Bool
    ) throws -> NSPersistentCloudKitContainer {
        let replacement = NSPersistentCloudKitContainer(
            name: PersistenceControllerConstants.weatherCoreData
        )

        guard let description = replacement.persistentStoreDescriptions.first else {
            throw PersistenceError.missingStoreDescription
        }

        description.url = storeURL

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        if inMemory || !syncEnabled {
            description.cloudKitContainerOptions = nil
        }

        return replacement
    }

    private func loadStores(in replacement: NSPersistentContainer) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            replacement.loadPersistentStores { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        replacement.viewContext.automaticallyMergesChangesFromParent = true
    }
}

private enum PersistenceControllerConstants {
    static let weatherCoreData = "WeatherCoreData"
    static let missingPersistentStoreDescription = "WeatherCoreData has no persistent store description."
    static let nullDevicePath = "/dev/null"
    static func unresolvedError(_ error: String, _ userInfo: String) -> String {
        "Unresolved error \(error), \(userInfo)"
    }
}
