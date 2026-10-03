//
//  PlaceCoreDataManagerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import XCTest
import CoreData
@testable import AzureSkys

final class PlaceCoreDataManagerTests: XCTestCase {
    private func store() -> (PlaceCoreDataManager, NSPersistentContainer) {
        let controller = PersistenceController(inMemory: true)
        return (PlaceCoreDataManager(container: controller.container), controller.container)
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

    func testLegacyAddressDataAndMalformedRecords() async throws {
        let (store, container) = store()
        try await container.performBackgroundTask { context in
            let legacy = PlaceEntity(entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!, insertInto: context)
            legacy.id = "legacy"
            legacy.addressComponents = Data(#"[{"long_name":"City","short_name":"C","types":["locality"]}]"#.utf8)
            let corrupt = PlaceEntity(entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!, insertInto: context)
            corrupt.id = "corrupt"
            corrupt.addressComponents = Data("invalid".utf8)
            _ = PlaceEntity(entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!, insertInto: context) // Missing identifiers must be filtered out.
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
        let json = Data(#"{"result":{"place_id":"city","name":"City","formatted_address":"City, USA","geometry":{"location":{"lat":12.5,"lng":-34.5}},"address_components":[{"long_name":"City","short_name":"C","types":["locality"]}]}}"#.utf8)
        let response = try JSONDecoder().decode(GooglePlaceDetailsResponse.self, from: json)
        let place = SavedPlace(details: response.result)
        XCTAssertEqual(place.id, "city")
        XCTAssertEqual(place.formattedAddress, "City, USA")
        XCTAssertEqual(place.latitude, 12.5)
        XCTAssertEqual(place.longitude, -34.5)
        XCTAssertEqual(place.addressComponents.first?.shortName, "C")
    }
}
