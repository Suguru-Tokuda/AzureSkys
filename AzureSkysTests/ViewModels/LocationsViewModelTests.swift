//
//  LocationsViewModelTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

@MainActor
final class LocationsViewModelTests: XCTestCase {
    func testDeletionErrorCanBeDismissedAndRetried() async {
        let store = PlaceStoreDouble()
        let vm = LocationsViewModel(placeCoreDataManager: store)
        store.error = NSError(domain: "Store", code: 1)
        await vm.removePlaces([testPlace, testPlace])
        XCTAssertEqual(store.deleted.count, 2)
        XCTAssertEqual(vm.coreDataError, .delete)
        vm.dismissError(); XCTAssertNil(vm.coreDataError)
        store.error = nil
        await vm.removePlaces([testPlace])
        XCTAssertNil(vm.coreDataError)
        await vm.removePlaces([])
        XCTAssertEqual(store.deleted.count, 3)
    }
}
