//
//  WeatherForecastViewModelTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

import CoreLocation

@MainActor
final class WeatherForecastViewModelTests: XCTestCase {
    func testSavedPlaceAndCurrentLocationLoadsAndRetry() async {
        let service = WeatherDouble(), store = PlaceStoreDouble()
        let vm = WeatherForecastViewModel(weatherService: service, coreDataManager: store)

        await vm.loadWeatherData(showLoading: true)
        XCTAssertTrue(service.coordinates.isEmpty)
        vm.setPlace(place: testPlace)
        await vm.loadWeatherData(showLoading: true)
        XCTAssertEqual(vm.loadingStatus, .loaded)
        XCTAssertEqual(vm.geocode?.name, PreviewManager.geocode.name)
        XCTAssertEqual(service.coordinates.last?.latitude, testPlace.latitude)
        service.error = URLError(.notConnectedToInternet)
        await vm.loadWeatherData(showLoading: false)
        XCTAssertEqual(vm.networkError, .networkUnavailable)
        XCTAssertNotNil(vm.forecast)
        service.error = nil
        vm.setPlace()
        vm.currentLocation = CLLocation(latitude: 45, longitude: 67)
        await vm.loadWeatherData(showLoading: true)
        XCTAssertNil(vm.networkError)
        XCTAssertEqual(service.coordinates.last?.latitude, 45)
    }

    func testCancelledRequestRestoresPriorForecastAndRejectsOverlappingLoad() async {
        let service = WeatherDouble()
        let vm = WeatherForecastViewModel(weatherService: service, coreDataManager: PlaceStoreDouble())

        vm.setPlace(place: testPlace)
        await vm.loadWeatherData(showLoading: true)
        service.pause = true

        let task = Task {
            await vm.loadWeatherData(showLoading: false)
        }

        while service.coordinates.count < 2 {
            await Task.yield()
        }

        await vm.loadWeatherData(showLoading: false)
        XCTAssertEqual(service.coordinates.count, 2)
        task.cancel()
        await task.value
        XCTAssertNil(vm.networkError)
        XCTAssertEqual(vm.loadingStatus, .loaded)
    }

    func testSaveFailureAndRecoveryDoNotChangeNetworkState() async {
        let store = PlaceStoreDouble()
        let vm = WeatherForecastViewModel(weatherService: WeatherDouble(), coreDataManager: store)

        store.error = CoreDataError.save

        let failure = expectation(description: "Save fails")

        vm.addPlace(place: testPlace) { result in
            if case .success = result {
                XCTFail("Expected failure")
            }

            failure.fulfill()
        }

        await fulfillment(of: [failure], timeout: 2)
        XCTAssertEqual(vm.coreDataError, .save)
        XCTAssertNil(vm.networkError)
        vm.dismissError()
        XCTAssertNil(vm.coreDataError)
        store.error = nil

        let success = expectation(description: "Save succeeds")

        vm.addPlace(place: testPlace) { result in
            if case .failure = result {
                XCTFail("Expected success")
            }

            success.fulfill()
        }

        await fulfillment(of: [success], timeout: 2)
        XCTAssertEqual(store.saved, [testPlace])
        vm.addPlace(place: nil) { _ in XCTFail("No save for missing place") }
    }

    func testLocationSubscriptionsAndRefreshLifecycle() async {
        let service = WeatherDouble()
        let vm = WeatherForecastViewModel(weatherService: service, coreDataManager: PlaceStoreDouble())
        let driver = LocationDriver()
        let location = LocationManager(startAutomatically: false, locationManager: driver)

        vm.setLocationManager(locationManager: location)
        vm.startDataRefreshTimer()
        driver.status = .authorizedWhenInUse
        location.locationManagerDidChangeAuthorization(driver)
        location.currentLocation = CLLocation(latitude: 1, longitude: 2)

        for _ in 0..<100 {
            if vm.forecast != nil && vm.locationAuthorized == true {
                break
            }

            try? await Task.sleep(for: .milliseconds(5))
        }

        XCTAssertNotNil(vm.forecast)
        XCTAssertEqual(vm.locationAuthorized, true)
        vm.endDataRefreshTimer()
        vm.setLocationManager(locationManager: location)
        XCTAssertEqual(vm.cancellables.count, 1)
    }
}
