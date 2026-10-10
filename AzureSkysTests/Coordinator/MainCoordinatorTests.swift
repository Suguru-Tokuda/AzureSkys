//
//  MainCoordinatorTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import XCTest
@testable import AzureSkys

@MainActor
final class MainCoordinatorTests: XCTestCase {
    func testSelectingSavedPlaceClosesLocationsAndUpdatesMainForecast() {
        let coordinator = MainCoordinator()

        coordinator.goToLocations()
        coordinator.selectLocation(testPlace)
        XCTAssertNil(coordinator.fullScreenDestination)
        XCTAssertEqual(coordinator.selectedLocation.place, testPlace)
        coordinator.goToLocations()
        coordinator.selectLocation(nil)
        XCTAssertNil(coordinator.selectedLocation.place)
    }

    func testNestedPreviewDismissalPreservesLocations() {
        let coordinator = MainCoordinator()

        coordinator.goToLocations()
        coordinator.previewForecast(place: testPlace)
        XCTAssertEqual(coordinator.forecastPreview?.place, testPlace)
        coordinator.dismissForecast()
        XCTAssertNil(coordinator.forecastPreview)
        XCTAssertEqual(coordinator.fullScreenDestination?.id, "locations")
    }

    func testRootForecastCarriesPlaceWithoutChangingMainSelection() {
        let coordinator = MainCoordinator()

        coordinator.selectLocation(testPlace)
        XCTAssertEqual(coordinator.fullScreenDestination?.id, "forecast:saved:test-city")
        XCTAssertNil(coordinator.selectedLocation.place)
        coordinator.dismissLocations()
        XCTAssertNotNil(coordinator.fullScreenDestination)
        coordinator.dismissForecast()
        XCTAssertNil(coordinator.fullScreenDestination)
    }
}
