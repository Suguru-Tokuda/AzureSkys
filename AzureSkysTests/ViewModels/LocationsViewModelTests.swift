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
    func testPlacesSortAlphabeticallyAndDeleteUsingDisplayedOrder() async {
        let store = PlaceStoreDouble()
        store.saved = ["Zurich", "amsterdam", "Boston"].map {
            SavedPlace(id: $0, name: $0, formattedAddress: "", latitude: 0, longitude: 0, addressComponents: [])
        }
        let vm = LocationsViewModel(placeCoreDataManager: store)
        await vm.loadPlaces()
        XCTAssertEqual(vm.places.map(\.name), ["amsterdam", "Boston", "Zurich"])
        await vm.removePlaces(at: IndexSet([0, 2, 99]))
        XCTAssertEqual(store.deleted.map(\.name), ["amsterdam", "Zurich"])
    }

    func testCancelledLoadPreservesPlacesAndDoesNotReportError() async {
        let store = PlaceStoreDouble()
        store.saved = [testPlace]
        let vm = LocationsViewModel(placeCoreDataManager: store)
        await vm.loadPlaces()
        store.saved = []
        let task = Task { await vm.loadPlaces() }
        task.cancel()
        await task.value
        XCTAssertEqual(vm.places, [testPlace])
        XCTAssertNil(vm.coreDataError)
    }

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
