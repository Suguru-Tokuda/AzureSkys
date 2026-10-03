//
//  LocationForecastViewModelTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import XCTest
@testable import AzureSkys

@MainActor
final class LocationForecastViewModelTests: XCTestCase {
    func testReplacementRejectsStaleSuccessAndError() async {
        for staleError in [nil, NetworkError.serverError] {
            let service = ControlledPlacesService()
            let vm = LocationForecastViewModel(placesService: service)
            let old = Task { await vm.getPredictions(searchText: "old") }
            await service.waitForRequest("old")
            let new = Task { await vm.getPredictions(searchText: "new") }
            await service.waitForRequest("new")
            await service.finish("new")
            await new.value
            await service.finish("old", error: staleError)
            await old.value
            XCTAssertEqual(vm.predictions.first?.placeId, "new")
            XCTAssertNil(vm.networkError)
        }
    }

    func testClearingSearchRejectsPendingResult() async {
        let service = ControlledPlacesService()
        let vm = LocationForecastViewModel(placesService: service)
        let request = Task { await vm.getPredictions(searchText: "city") }
        await service.waitForRequest("city")
        vm.searchText = "   "
        await service.finish("city")
        await request.value
        XCTAssertTrue(vm.predictions.isEmpty)
        XCTAssertEqual(vm.loadingStatus, .inactive)
    }

    func testFailureThenRetryRecovers() async {
        let service = ControlledPlacesService()
        let vm = LocationForecastViewModel(placesService: service)
        let failed = Task { await vm.getPredictions(searchText: "city") }
        await service.waitForRequest("city")
        await service.finish("city", error: .networkUnavailable)
        await failed.value
        XCTAssertEqual(vm.networkError, .networkUnavailable)
        let retry = Task { await vm.getPredictions(searchText: "city") }
        await service.waitForRequest("city")
        await service.finish("city")
        await retry.value
        XCTAssertNil(vm.networkError)
        XCTAssertEqual(vm.predictions.first?.placeId, "city")
    }

    func testDetailsFailureDoesNotReplaceSearchState() async {
        let vm = LocationForecastViewModel(placesService: ControlledPlacesService())
        let place = await vm.getPlaceDetails(placeId: "city")
        XCTAssertNil(place)
        XCTAssertEqual(vm.detailsError, .networkUnavailable)
        XCTAssertNil(vm.networkError)
        vm.dismissError()
        XCTAssertNil(vm.detailsError)
    }

    func testPendingDebounceDoesNotRetainViewModel() {
        var vm: LocationForecastViewModel? = LocationForecastViewModel(placesService: ControlledPlacesService())
        weak var weakVM = vm
        vm?.searchText = "city"
        vm = nil
        XCTAssertNil(weakVM)
    }
}
