//
//  AppDependenciesTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

import CoreLocation

@MainActor
final class AppDependenciesTests: XCTestCase {
    func testFactoriesUseInjectedServicesAndStore() async throws {
        let service = WeatherDouble(), store = PlaceStoreDouble()
        let controller = PersistenceController(inMemory: true)
        let dependencies = AppDependencies(weatherService: service, placesService: ControlledPlacesService(), placeStore: store, persistenceController: controller, locationManager: LocationManager(startAutomatically: false), coordinator: MainCoordinator(), fileManager: LocalFileManager(directory: nil), settingsManager: SettingsManager(canOpen: { _ in false }, open: { _ in }))
        let forecast = dependencies.makeWeatherForecastViewModel()
        forecast.setPlace(place: testPlace)
        await forecast.loadWeatherData(showLoading: true)
        XCTAssertEqual(service.coordinates.count, 1)
        let current = dependencies.makeCurrentWeatherViewModel()
        current.setPlace(place: testPlace)
        await current.loadCurrentWeatherData(showLoading: true)
        XCTAssertEqual(service.coordinates.count, 2)
        XCTAssertTrue(dependencies.makeLocationSearchViewModel().predictions.isEmpty)
        let locations = dependencies.makeLocationsViewModel()
        await locations.removePlaces([testPlace])
        XCTAssertEqual(store.deleted, [testPlace])
    }

    func testPreviewUsesAuthorizedLocationAndIsolatedStore() async throws {
        let first = AppDependencies.preview(), second = AppDependencies.preview()
        XCTAssertEqual(first.locationManager.locationAuthorized, true)
        XCTAssertNotNil(first.locationManager.currentLocation)
        try await first.placeStore.savePlaceIntoDatabase(place: testPlace)
        let secondPlaces = try await second.placeStore.getPlacesFromDatabase()
        XCTAssertTrue(secondPlaces.isEmpty)
        let place = try await first.placesService.getPlaceDetails(placeID: "preview")
        XCTAssertEqual(place.name, "Chicago")
        let predictions = try await first.placesService.getPredictions(query: "Chicago")
        XCTAssertFalse(predictions.isEmpty)
        let coordinate = CLLocationCoordinate2D(latitude: 1, longitude: 2)
        let forecast = try await first.weatherService.getForecast(coordinate: coordinate)
        XCTAssertFalse(forecast.forecast.daily.isEmpty)
        let current = try await first.weatherService.getCurrentWeather(coordinate: coordinate)
        XCTAssertEqual(current.coordinate.latitude, 1)
    }
}
