//
//  PersistenceControllerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import CoreData
@testable import AzureSkys

final class PersistenceControllerTests: XCTestCase {
    func testTemporaryContainersAreIsolatedAndMergeChanges() throws {
        let first = PersistenceController(inMemory: true)
        let second = PersistenceController(inMemory: true)
        XCTAssertTrue(first.container.viewContext.automaticallyMergesChangesFromParent)
        let context = first.container.viewContext
        let place = PlaceEntity(entity: NSEntityDescription.entity(forEntityName: "PlaceEntity", in: context)!, insertInto: context); place.id = "first"
        try context.save()
        XCTAssertEqual(try second.container.viewContext.count(for: PlaceEntity.fetchRequest()), 0)
        XCTAssertFalse(PersistenceController.preview.container.persistentStoreCoordinator.persistentStores.isEmpty)
    }
}
