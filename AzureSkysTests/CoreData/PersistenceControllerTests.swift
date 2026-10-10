import XCTest
import CoreData
@testable import AzureSkys

@MainActor
final class PersistenceControllerTests: XCTestCase {
    func testStartupDoesNotEraseAnErrorReportedByTheSyncEngine() async throws {
        let sync = SyncDouble()
        let persistence = PersistenceController(inMemory: true, syncCoordinatorFactory: { _ in sync })

        sync.onStart = { [weak persistence] in
            persistence?.reportSyncError(CoreDataError.save)
        }

        try await persistence.setSyncEnabled(true)
        XCTAssertTrue(persistence.syncEnabled)
        XCTAssertNotNil(persistence.accountChangeError)
    }

    func testTemporaryContainersAreIsolatedAndMergeChanges() throws {
        let first = PersistenceController(inMemory: true)
        let second = PersistenceController(inMemory: true)

        XCTAssertTrue(first.viewContext.automaticallyMergesChangesFromParent)

        let place = PlaceEntity(
            entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: first.viewContext)!,
            insertInto: first.viewContext
        )
        place.id = "first"
        try first.viewContext.save()
        XCTAssertEqual(try second.viewContext.count(for: PlaceEntity.fetchRequest()), 0)
    }

    func testSyncDisableAndAccountUnavailabilityKeepLocalContextAndLocations() async throws {
        let sync = SyncDouble()
        let persistence = PersistenceController(inMemory: true, syncCoordinatorFactory: { _ in sync })
        let manager = PlaceCoreDataManager(persistence: persistence)
        let context = persistence.viewContext

        try await manager.savePlaceIntoDatabase(place: testPlace)
        try await persistence.setSyncEnabled(true)
        XCTAssertTrue(persistence.syncEnabled)
        sync.available = false
        try await persistence.setSyncEnabled(true)
        XCTAssertFalse(persistence.syncEnabled)
        try await persistence.setSyncEnabled(false)
        XCTAssertTrue(context === persistence.viewContext)
        XCTAssertNil(persistence.container.persistentStoreDescriptions[0].cloudKitContainerOptions)

        let places = try await manager.getPlacesFromDatabase()

        XCTAssertEqual(places, [testPlace])

        let pending = try await persistence.pendingLocationChanges()

        XCTAssertEqual(pending.first?.action, "upsert")
    }

    func testFailedLocationEditCannotCommitAJournalEntryOrLocation() async throws {
        let persistence = PersistenceController(inMemory: true)

        do {
            try await persistence.performLocationChange { context in
                let entity = PlaceEntity(
                    entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                    insertInto: context
                )
                entity.id = "incomplete"

                throw CoreDataError.save
            }

            XCTFail("Expected the edit to fail")
        } catch {}

        let pending = try await persistence.pendingLocationChanges()
        let places = try await PlaceCoreDataManager(persistence: persistence).getPlacesFromDatabase()

        XCTAssertTrue(pending.isEmpty)
        XCTAssertTrue(places.isEmpty)
    }

    func testBridgeModelMigratesWithoutLosingPendingDeletions() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let url = directory.appendingPathComponent("Locations.sqlite")
        let modelURL = try XCTUnwrap(
            Bundle(for: PersistenceController.self).url(forResource: "WeatherLocalCoreData", withExtension: "momd")
        )

        let model = try XCTUnwrap(
            NSManagedObjectModel(contentsOf: modelURL.appendingPathComponent("WeatherLocalCoreData.mom"))
        )

        let old = NSPersistentContainer(name: "WeatherLocalCoreData", managedObjectModel: model)

        old.persistentStoreDescriptions[0].url = url.deletingPathExtension().appendingPathExtension("local.sqlite")
        old.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        old.loadPersistentStores { _, error in XCTAssertNil(error) }

        let action = NSEntityDescription.insertNewObject(forEntityName: "LocalSyncAction", into: old.viewContext)

        action.setValue(testPlace.id, forKey: "id")
        action.setValue("delete", forKey: "action")
        try old.viewContext.save()

        for store in old.persistentStoreCoordinator.persistentStores {
            try old.persistentStoreCoordinator.remove(store)
        }

        let persistence = PersistenceController(storeURL: url)
        let pending = try await persistence.pendingLocationChanges()

        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending.first?.action, "delete")
        XCTAssertFalse(pending.first?.revision.isEmpty ?? true)
    }

    func testLocalLocationsAndPendingDeletionsSurviveRelaunch() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let url = directory.appendingPathComponent("Locations.sqlite")
        var persistence: PersistenceController? = PersistenceController(storeURL: url)
        var manager: PlaceCoreDataManager? = PlaceCoreDataManager(persistence: persistence!)

        try await manager!.savePlaceIntoDatabase(place: testPlace)
        manager = nil
        persistence = nil
        persistence = PersistenceController(storeURL: url)
        manager = PlaceCoreDataManager(persistence: persistence!)

        var places = try await manager!.getPlacesFromDatabase()

        XCTAssertEqual(places, [testPlace])
        try await manager!.deleteFromDatabase(place: testPlace)

        let actions = try await persistence!.performBackgroundTask { context in
            try context.fetch(NSFetchRequest<NSManagedObject>(entityName: "LocalSyncAction"))
                .map { $0.value(forKey: "action") as? String }
        }

        XCTAssertEqual(actions, ["delete"])
        manager = nil
        persistence = nil
        persistence = PersistenceController(storeURL: url)
        manager = PlaceCoreDataManager(persistence: persistence!)
        places = try await manager!.getPlacesFromDatabase()
        XCTAssertTrue(places.isEmpty)

        let persistedActions = try await persistence!.performBackgroundTask { context in
            try context.fetch(NSFetchRequest<NSManagedObject>(entityName: "LocalSyncAction"))
                .map { $0.value(forKey: "action") as? String }
        }

        XCTAssertEqual(persistedActions, ["delete"])
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.appendingPathExtension("locations.json").path))
    }

    func testLegacyDatabaseMigratesToLocalOnlyStoreOnce() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let url = directory.appendingPathComponent("Legacy.sqlite")
        let legacy = NSPersistentContainer(name: "WeatherCoreData")

        legacy.persistentStoreDescriptions[0].url = url
        legacy.loadPersistentStores { _, error in XCTAssertNil(error) }

        let entity = PlaceEntity(
            entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: legacy.viewContext)!,
            insertInto: legacy.viewContext
        )
        entity.id = testPlace.id
        entity.name = testPlace.name
        entity.formattedAddress = testPlace.formattedAddress
        entity.latitude = testPlace.latitude
        entity.longitude = testPlace.longitude
        entity.addressComponents = try JSONEncoder().encode(testPlace.addressComponents)
        try legacy.viewContext.save()

        for store in legacy.persistentStoreCoordinator.persistentStores {
            try legacy.persistentStoreCoordinator.remove(store)
        }

        var persistence: PersistenceController? = PersistenceController(storeURL: url)
        var manager: PlaceCoreDataManager? = PlaceCoreDataManager(persistence: persistence!)
        var places = try await manager!.getPlacesFromDatabase()

        XCTAssertEqual(places, [testPlace])
        XCTAssertNotEqual(persistence!.container.persistentStoreDescriptions[0].url, url)
        try await manager!.deleteFromDatabase(place: testPlace)
        manager = nil
        persistence = nil
        persistence = PersistenceController(storeURL: url)
        manager = PlaceCoreDataManager(persistence: persistence!)
        places = try await manager!.getPlacesFromDatabase()
        XCTAssertTrue(places.isEmpty, "Legacy migration must not resurrect a deleted location")
    }
}

@MainActor
private final class SyncDouble: LocationSyncControlling {
    var available = true
    var isRunning = false
    var onStart: (() -> Void)?

    func start() async throws {
        isRunning = available
        onStart?()
    }

    func stop() async {
        isRunning = false
    }

    func enqueueLocalChanges() async throws {}
}
