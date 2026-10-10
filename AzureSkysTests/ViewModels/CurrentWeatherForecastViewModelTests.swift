//
//  CurrentWeatherForecastViewModelTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

import CoreLocation

@MainActor
final class CurrentWeatherForecastViewModelTests: XCTestCase {
    func testMissingCoordinatesSavedCityAndCurrentLocation() async {
        let service = WeatherDouble()
        let vm = CurrentWeatherForecastViewModel(weatherService: service)
        await vm.getCurrentWeatherDataWithCityData()
        await vm.loadCurrentWeatherData(showLoading: true)
        XCTAssertTrue(service.coordinates.isEmpty)
        vm.setPlace(place: testPlace)
        await vm.loadCurrentWeatherData(showLoading: true)
        XCTAssertEqual(vm.loadingStatus, .loaded)
        XCTAssertEqual(vm.currentForecast?.name, "Test City")
        XCTAssertEqual(service.coordinates.last?.longitude, testPlace.longitude)
        vm.place = nil; vm.currentLocation = CLLocation(latitude: 45, longitude: 67)
        await vm.loadCurrentWeatherData(showLoading: true)
        XCTAssertEqual(service.coordinates.last?.latitude, 45)
    }

    func testFailureRecoveryAndCancellationRetainPreviousData() async {
        let service = WeatherDouble()
        let vm = CurrentWeatherForecastViewModel(weatherService: service)
        vm.setPlace(place: testPlace)
        await vm.loadCurrentWeatherData(showLoading: true)
        service.error = NetworkError.serverError
        await vm.loadCurrentWeatherData(showLoading: false)
        XCTAssertEqual(vm.requestState.error, .serverError)
        XCTAssertNotNil(vm.currentForecast)
        service.error = nil; service.pause = true
        let task = Task { await vm.loadCurrentWeatherData(showLoading: false) }
        while service.coordinates.count < 3 { await Task.yield() }
        await vm.loadCurrentWeatherData(showLoading: false)
        XCTAssertEqual(service.coordinates.count, 3)
        task.cancel(); await task.value
        XCTAssertEqual(vm.loadingStatus, .loaded)
        XCTAssertNil(vm.requestState.error)
    }

    func testLocationSubscriptionsAndScheduler() async {
        let vm = CurrentWeatherForecastViewModel(weatherService: WeatherDouble())
        let driver = LocationDriver()
        let location = LocationManager(startAutomatically: false, locationManager: driver)
        vm.setLocationManager(locationManager: location)
        vm.startDataRefreshTimer()
        location.currentLocation = CLLocation(latitude: 1, longitude: 2)
        driver.status = .authorizedWhenInUse
        location.locationManagerDidChangeAuthorization(driver)
        for _ in 0..<100 { if vm.currentForecast != nil && vm.locationAuthorized == true { break }; try? await Task.sleep(for: .milliseconds(5)) }
        XCTAssertNotNil(vm.currentForecast)
        XCTAssertEqual(vm.locationAuthorized, true)
        vm.endDataRefreshTimer()
        vm.setLocationManager(locationManager: location)
        XCTAssertEqual(vm.cancellables.count, 1)
    }
}
