import XCTest
import CoreData
@testable import AzureSkys

@MainActor
final class PersistenceControllerTests: XCTestCase {
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

    func testInMemorySyncToggleKeepsLocalLocationsAndDisablesMirroring() async throws {
        let persistence = PersistenceController(inMemory: true)
        let manager = PlaceCoreDataManager(persistence: persistence)
        try await manager.savePlaceIntoDatabase(place: testPlace)
        try await persistence.setSyncEnabled(true)
        XCTAssertFalse(persistence.syncEnabled)
        XCTAssertNil(persistence.container.persistentStoreDescriptions[0].cloudKitContainerOptions)
        try await persistence.setSyncEnabled(false)
        let places = try await manager.getPlacesFromDatabase()
        XCTAssertEqual(places, [testPlace])
    }

    func testFailedLocationEditCannotCommitLocation() async throws {
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

        let places = try await PlaceCoreDataManager(persistence: persistence).getPlacesFromDatabase()

        XCTAssertTrue(places.isEmpty)
    }

    func testBridgeModelMigratesPendingDeletions() async throws {
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

        let original = NSPersistentContainer(name: "WeatherCoreData")
        original.persistentStoreDescriptions[0].url = url
        original.persistentStoreDescriptions[0].shouldAddStoreAsynchronously = false
        original.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        original.loadPersistentStores { _, error in XCTAssertNil(error) }
        try PlaceCoreDataManager.upsert(testPlace, in: original.viewContext)
        try original.viewContext.save()
        for store in original.persistentStoreCoordinator.persistentStores {
            try original.persistentStoreCoordinator.remove(store)
        }

        let old = NSPersistentContainer(name: "WeatherLocalCoreData", managedObjectModel: model)

        old.persistentStoreDescriptions[0].url = url.deletingPathExtension().appendingPathExtension("local.sqlite")
        old.persistentStoreDescriptions[0].setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        old.loadPersistentStores { _, error in XCTAssertNil(error) }

        let action = NSEntityDescription.insertNewObject(forEntityName: "LocalSyncAction", into: old.viewContext)

        action.setValue(testPlace.id, forKey: "id")
        action.setValue("delete", forKey: "action")
        let retainedPlace = SavedPlace(
            id: "retained",
            name: testPlace.name,
            formattedAddress: testPlace.formattedAddress,
            latitude: testPlace.latitude,
            longitude: testPlace.longitude,
            addressComponents: testPlace.addressComponents
        )
        try PlaceCoreDataManager.upsert(retainedPlace, in: old.viewContext)
        try old.viewContext.save()

        for store in old.persistentStoreCoordinator.persistentStores {
            try old.persistentStoreCoordinator.remove(store)
        }

        let persistence = PersistenceController(storeURL: url)

        let places = try await PlaceCoreDataManager(persistence: persistence).getPlacesFromDatabase()
        XCTAssertEqual(places, [retainedPlace])
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: url.deletingPathExtension().appendingPathExtension("local.sqlite").path
            )
        )
    }

    func testLocalLocationsAndDeletionsSurviveRelaunch() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let url = directory.appendingPathComponent("Locations.sqlite")
        var persistence: PersistenceController? = PersistenceController(
            storeURL: url
        )
        var manager: PlaceCoreDataManager? = PlaceCoreDataManager(persistence: persistence!)

        try await manager!.savePlaceIntoDatabase(place: testPlace)
        manager = nil
        persistence = nil
        persistence = PersistenceController(storeURL: url)
        manager = PlaceCoreDataManager(persistence: persistence!)

        var places = try await manager!.getPlacesFromDatabase()

        XCTAssertEqual(places, [testPlace])
        try await manager!.deleteFromDatabase(place: testPlace)

        manager = nil
        persistence = nil
        persistence = PersistenceController(storeURL: url)
        manager = PlaceCoreDataManager(persistence: persistence!)
        places = try await manager!.getPlacesFromDatabase()
        XCTAssertTrue(places.isEmpty)

        XCTAssertFalse(FileManager.default.fileExists(atPath: url.appendingPathExtension("locations.json").path))
    }

    func testExistingDatabaseIsReusedWithoutResurrectingDeletions() async throws {
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

        var persistence: PersistenceController? = PersistenceController(
            storeURL: url
        )
        var manager: PlaceCoreDataManager? = PlaceCoreDataManager(persistence: persistence!)
        var places = try await manager!.getPlacesFromDatabase()

        XCTAssertEqual(places, [testPlace])
        XCTAssertEqual(persistence!.container.persistentStoreDescriptions[0].url, url)
        try await manager!.deleteFromDatabase(place: testPlace)
        manager = nil
        persistence = nil
        persistence = PersistenceController(storeURL: url)
        manager = PlaceCoreDataManager(persistence: persistence!)
        places = try await manager!.getPlacesFromDatabase()
        XCTAssertTrue(places.isEmpty, "Legacy migration must not resurrect a deleted location")
    }
}
