//
//  PlaceCoreDataManagerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import XCTest
import CoreData
@testable import AzureSkys

@MainActor
final class PlaceCoreDataManagerTests: XCTestCase {
    private func store() -> (PlaceCoreDataManager, NSPersistentContainer) {
        let controller = PersistenceController(inMemory: true)

        return (PlaceCoreDataManager(persistence: controller), controller.container)
    }

    func testExistingManagerReadsAndWritesAfterContainerReplacement() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let persistence = PersistenceController(storeURL: directory.appendingPathComponent("places.sqlite"))
        let manager = PlaceCoreDataManager(persistence: persistence)

        try await manager.savePlaceIntoDatabase(place: testPlace)

        let oldContext = persistence.viewContext

        try await persistence.reloadStore(syncEnabled: false)

        XCTAssertFalse(oldContext === persistence.viewContext)
        XCTAssertTrue(persistence.viewContext === persistence.container.viewContext)

        let places = try await manager.getPlacesFromDatabase()

        XCTAssertEqual(places, [testPlace])
        try await manager.deleteFromDatabase(place: testPlace)

        let remaining = try await manager.getPlacesFromDatabase()

        XCTAssertTrue(remaining.isEmpty)
    }

    func testSaveRoundTripAndDuplicateProtection() async throws {
        let (store, _) = store()

        try await store.savePlaceIntoDatabase(place: testPlace)
        try await store.savePlaceIntoDatabase(place: testPlace)

        let saved = try await store.getPlaceFromDatabase(id: testPlace.id)
        let all = try await store.getPlacesFromDatabase()

        XCTAssertEqual(saved, testPlace)
        XCTAssertEqual(all.count, 1)
    }

    func testDeleteClearAndMissingLookup() async throws {
        let (store, _) = store()
        let missing = try await store.getPlaceFromDatabase(id: "missing")

        XCTAssertNil(missing)
        try await store.savePlaceIntoDatabase(place: testPlace)
        try await store.deleteFromDatabase(place: testPlace)

        let deleted = try await store.getPlaceFromDatabase(id: testPlace.id)

        XCTAssertNil(deleted)
        try await store.savePlaceIntoDatabase(place: testPlace)
        try await store.clearAllFromDatabase()

        let all = try await store.getPlacesFromDatabase()

        XCTAssertTrue(all.isEmpty)
    }

    func testDuplicateImportedRowsAreRemovedFromPersistentStore() async throws {
        let (store, container) = store()
        try await store.savePlaceIntoDatabase(place: testPlace)

        // Bypass the local save guard, as a cloud import can do.
        for _ in 0..<2 {
            try await container.performBackgroundTask { context in
                let duplicate = PlaceEntity(
                    entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                    insertInto: context
                )
                duplicate.id = testPlace.id
                duplicate.name = testPlace.name
                duplicate.formattedAddress = testPlace.formattedAddress
                duplicate.latitude = testPlace.latitude
                duplicate.longitude = testPlace.longitude
                duplicate.addressComponents = try JSONEncoder().encode(testPlace.addressComponents)
                let distinct = PlaceEntity(
                    entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                    insertInto: context
                )
                distinct.id = "other-place"
                distinct.name = testPlace.name
                try context.save()
            }

            let places = try await store.getPlacesFromDatabase()
            XCTAssertEqual(places.count, 2)
            XCTAssertEqual(places.filter { $0.id == testPlace.id }, [testPlace])
            let rowCount = try await container.performBackgroundTask { context in
                try context.count(for: PlaceEntity.fetchRequest())
            }
            XCTAssertEqual(rowCount, 2, "Duplicates must be deleted from Core Data, not just filtered from results")
        }

        try await store.deleteFromDatabase(place: testPlace)
        let remaining = try await store.getPlacesFromDatabase()
        XCTAssertEqual(remaining.map(\.id), ["other-place"])
        let deletedRowCount = try await container.performBackgroundTask { context in
            let request = PlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", testPlace.id)
            return try context.count(for: request)
        }
        XCTAssertEqual(deletedRowCount, 0)
    }

    func testReconciliationUsesSameCloudIdentityAcrossDifferentInsertionOrders() throws {
        for names in [["record-b", "record-a"], ["record-a", "record-b"]] {
            let (_, container) = store()
            let context = container.viewContext
            for name in names {
                let entity = PlaceEntity(
                    entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                    insertInto: context
                )
                entity.id = testPlace.id
                entity.name = name
            }
            try context.save()
            try PlaceCoreDataManager.reconcileDuplicates(in: context) { $0.name }
            try context.save()
            XCTAssertEqual(try context.fetch(PlaceEntity.fetchRequest()).map(\.name), ["record-a"])
            try PlaceCoreDataManager.reconcileDuplicates(in: context) { $0.name }
            XCTAssertFalse(context.hasChanges, "Repeated reconciliation must not generate more exports")
        }
    }

    func testReconciliationKeepsExistingCloudRecordOverNewLocalDuplicate() throws {
        let (_, container) = store()
        let context = container.viewContext
        for name in ["record-a", "awaiting-export"] {
            let entity = PlaceEntity(
                entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                insertInto: context
            )
            entity.id = testPlace.id
            entity.name = name
        }
        try context.save()
        try PlaceCoreDataManager.reconcileDuplicates(in: context) {
            $0.name == "awaiting-export" ? nil : $0.name
        }
        try context.save()
        XCTAssertEqual(try context.fetch(PlaceEntity.fetchRequest()).map(\.name), ["record-a"])
    }

    func testLegacyAddressDataAndMalformedRecords() async throws {
        let (store, container) = store()

        try await container.performBackgroundTask { context in
            let legacy = PlaceEntity(
                entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                insertInto: context
            )
            legacy.id = "legacy"
            legacy.addressComponents = Data(#"[{"long_name":"City","short_name":"C","types":["locality"]}]"#.utf8)

            let corrupt = PlaceEntity(
                entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                insertInto: context
            )
            corrupt.id = "corrupt"
            corrupt.addressComponents = Data("invalid".utf8)
            _ = PlaceEntity(
                entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                insertInto: context
            )  // Missing identifiers must be filtered out.
            try context.save()
        }

        let legacy = try await store.getPlaceFromDatabase(id: "legacy")
        let corrupt = try await store.getPlaceFromDatabase(id: "corrupt")
        let all = try await store.getPlacesFromDatabase()

        XCTAssertEqual(legacy?.addressComponents.first?.shortName, "C")
        XCTAssertEqual(corrupt?.addressComponents, [])
        XCTAssertEqual(all.count, 2)
    }

    func testAPIResponseMapsIntoIndependentPlaceModel() throws {
        let json = Data(
            #"{"result":{"place_id":"city","name":"City","formatted_address":"City, USA","geometry":{"location":{"lat":12.5,"lng":-34.5}},"address_components":[{"long_name":"City","short_name":"C","types":["locality"]}]}}"#
                .utf8
        )

        let response = try JSONDecoder().decode(GooglePlaceDetailsResponse.self, from: json)
        let place = SavedPlace(details: response.result)

        XCTAssertEqual(place.id, "city")
        XCTAssertEqual(place.formattedAddress, "City, USA")
        XCTAssertEqual(place.latitude, 12.5)
        XCTAssertEqual(place.longitude, -34.5)
        XCTAssertEqual(place.addressComponents.first?.shortName, "C")
    }
}
