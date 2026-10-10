//
//  CloudKitLocationSyncTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/7/26.
//

import XCTest
import CloudKit
import CoreData
@testable import AzureSkys

@MainActor
final class CloudKitLocationSyncTests: XCTestCase {
    func testAcknowledgedRecordsRestoreIntoAnEmptyInstallation() async throws {
        let original = PersistenceController(inMemory: true)

        try await PlaceCoreDataManager(persistence: original).savePlaceIntoDatabase(place: testPlace)

        let pending = try await original.pendingLocationChanges()
        let savedRecord = try await original.recordForSync(testPlace.id)
        let record = try XCTUnwrap(savedRecord)

        try await original.acknowledgeLocationChanges(
            saved: [record],
            deleted: [],
            sent: Dictionary(uniqueKeysWithValues: pending.map { ($0.id, $0) })
        )

        let remaining = try await original.pendingLocationChanges()

        XCTAssertTrue(remaining.isEmpty)

        // A reinstall has neither the old SQLite store nor the old sync cursor.
        let reinstalled = PersistenceController(inMemory: true)

        XCTAssertNil(try reinstalled.metadata("ckSyncState"))
        try await reinstalled.applyRemoteLocations([record], deletedIDs: [])

        let restored = try await PlaceCoreDataManager(persistence: reinstalled).getPlacesFromDatabase()

        XCTAssertEqual(restored, [testPlace])

        let uploads = try await reinstalled.pendingLocationChanges()

        XCTAssertTrue(uploads.isEmpty)
    }

    func testCloudRecordRoundTripAndSystemFieldsRestore() throws {
        let record = try LocationCloudRecord.make(testPlace, systemFields: nil)

        XCTAssertEqual(try LocationCloudRecord.place(from: record), testPlace)

        let restored = try LocationCloudRecord.make(
            testPlace,
            systemFields: LocationCloudRecord.systemFields(of: record)
        )
        XCTAssertEqual(restored.recordID, record.recordID)
        XCTAssertEqual(try LocationCloudRecord.place(from: restored), testPlace)
    }

    func testRemoteAddUpdateDeleteAndRepeatedImports() async throws {
        let persistence = PersistenceController(inMemory: true)
        let manager = PlaceCoreDataManager(persistence: persistence)
        let record = try LocationCloudRecord.make(testPlace, systemFields: nil)

        try await persistence.applyRemoteLocations([record], deletedIDs: [])
        try await persistence.applyRemoteLocations([record], deletedIDs: [])

        var places = try await manager.getPlacesFromDatabase()

        XCTAssertEqual(places, [testPlace])
        record["name"] = "Updated City" as CKRecordValue
        try await persistence.applyRemoteLocations([record], deletedIDs: [])
        places = try await manager.getPlacesFromDatabase()
        XCTAssertEqual(places.first?.name, "Updated City")
        try await persistence.applyRemoteLocations([], deletedIDs: [record.recordID])
        places = try await manager.getPlacesFromDatabase()
        XCTAssertTrue(places.isEmpty)

        let pending = try await persistence.pendingLocationChanges()

        XCTAssertTrue(pending.isEmpty, "Imports must not create an upload feedback loop")
    }

    func testLateSaveAcknowledgementCannotClearNewerOfflineDeletion() async throws {
        let persistence = PersistenceController(inMemory: true)
        let manager = PlaceCoreDataManager(persistence: persistence)

        try await manager.savePlaceIntoDatabase(place: testPlace)

        let originalChanges = try await persistence.pendingLocationChanges()
        let original = try XCTUnwrap(originalChanges.first)
        let uploadRecord = try await persistence.recordForSync(testPlace.id)
        let record = try XCTUnwrap(uploadRecord)

        try await manager.deleteFromDatabase(place: testPlace)

        let deletionChanges = try await persistence.pendingLocationChanges()
        let deletion = try XCTUnwrap(deletionChanges.first)

        XCTAssertNotEqual(original.revision, deletion.revision)
        try await persistence.acknowledgeLocationChanges(saved: [record], deleted: [], sent: [original.id: original])
        try await persistence.applyRemoteLocations([record], deletedIDs: [])

        let places = try await manager.getPlacesFromDatabase()
        let remaining = try await persistence.pendingLocationChanges()

        XCTAssertTrue(places.isEmpty)
        XCTAssertEqual(remaining, [deletion])
        try await persistence.acknowledgeLocationChanges(
            saved: [],
            deleted: [record.recordID],
            sent: [deletion.id: deletion]
        )

        let acknowledged = try await persistence.pendingLocationChanges()

        XCTAssertTrue(acknowledged.isEmpty)
    }

    func testLateDeleteAcknowledgementCannotClearReaddedLocation() async throws {
        let persistence = PersistenceController(inMemory: true)
        let manager = PlaceCoreDataManager(persistence: persistence)

        try await manager.savePlaceIntoDatabase(place: testPlace)
        try await manager.deleteFromDatabase(place: testPlace)

        let deletionChanges = try await persistence.pendingLocationChanges()
        let deletion = try XCTUnwrap(deletionChanges.first)

        try await manager.savePlaceIntoDatabase(place: testPlace)

        let latest = try await persistence.pendingLocationChanges()

        try await persistence.acknowledgeLocationChanges(
            saved: [],
            deleted: [LocationCloudRecord.recordID(testPlace.id)],
            sent: [deletion.id: deletion]
        )

        let remaining = try await persistence.pendingLocationChanges()
        let places = try await manager.getPlacesFromDatabase()

        XCTAssertEqual(remaining, latest)
        XCTAssertEqual(places, [testPlace])
    }

    func testLegacyCloudImportPreservesOfflineDeletionsAndExistingLocations() async throws {
        let persistence = PersistenceController(inMemory: true)
        let manager = PlaceCoreDataManager(persistence: persistence)

        try await manager.savePlaceIntoDatabase(place: testPlace)
        try await manager.deleteFromDatabase(place: testPlace)

        let legacy = CKRecord(
            recordType: "CD_PlaceEntity",
            recordID: .init(recordName: "legacy-object", zoneID: LocationCloudRecord.legacyZoneID)
        )
        legacy["CD_id"] = testPlace.id as CKRecordValue
        legacy["CD_name"] = testPlace.name as CKRecordValue
        legacy["CD_latitude"] = testPlace.latitude as CKRecordValue
        legacy["CD_longitude"] = testPlace.longitude as CKRecordValue
        legacy["CD_addressComponents"] = try JSONEncoder().encode(testPlace.addressComponents) as CKRecordValue

        let decoded = try XCTUnwrap(LocationCloudRecord.legacyPlace(from: legacy))

        XCTAssertEqual(decoded.addressComponents, testPlace.addressComponents)
        try await persistence.importLegacyCloudLocations([decoded])

        let places = try await manager.getPlacesFromDatabase()

        XCTAssertTrue(places.isEmpty)
    }

    func testMalformedRemoteBatchDoesNotPartiallyCommit() async throws {
        let persistence = PersistenceController(inMemory: true)
        let valid = try LocationCloudRecord.make(testPlace, systemFields: nil)
        let invalid = CKRecord(
            recordType: LocationCloudRecord.recordType,
            recordID: LocationCloudRecord.recordID("bad")
        )

        do {
            try await persistence.applyRemoteLocations([valid, invalid], deletedIDs: [])
            XCTFail("Expected invalid record")
        } catch {}

        let places = try await PlaceCoreDataManager(persistence: persistence).getPlacesFromDatabase()

        XCTAssertTrue(places.isEmpty)
    }

    func testAccountSwitchIsRejectedWithoutRemovingLocalData() async throws {
        let persistence = PersistenceController(inMemory: true)
        let manager = PlaceCoreDataManager(persistence: persistence)

        try await manager.savePlaceIntoDatabase(place: testPlace)
        try persistence.bindSyncAccount("first-account")
        try persistence.bindSyncAccount("first-account")
        XCTAssertThrowsError(try persistence.bindSyncAccount("second-account"))

        let places = try await manager.getPlacesFromDatabase()

        XCTAssertEqual(places, [testPlace])
        XCTAssertEqual(try persistence.metadata("syncAccount"), Data("first-account".utf8))
    }

    func testNativeBatchesRespectCloudKitLimit() async throws {
        let persistence = PersistenceController(inMemory: true)

        try await persistence.performLocationChange { context in
            for index in 0..<251 {
                let entity = PlaceEntity(
                    entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!,
                    insertInto: context
                )
                entity.id = "place-\(index)"
            }
        }

        let sync = CloudKitLocationSync(persistence: persistence)
        let changes = try await persistence.pendingLocationChanges()
        let batch = try await sync.prepareBatch(changes)

        XCTAssertEqual(batch?.recordsToSave.count, 250)
        XCTAssertEqual(changes.count, 251)
        XCTAssertTrue(batch?.recordIDsToDelete.isEmpty ?? false)
    }
}
