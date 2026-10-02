//
//  AppDependencies.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/1/26.
//

import SwiftUI
import CoreLocation

@MainActor
final class AppDependencies: ObservableObject {
    let weatherService: WeatherServicing
    let placesService: PlacesServicing
    let placeStore: PlaceCoreDataActions
    let persistenceController: PersistenceController
    let locationManager: LocationManager
    let coordinator: MainCoordinator
    let fileManager: LocalFileManager
    let settingsManager: SettingsManager

    init(weatherService: WeatherServicing, placesService: PlacesServicing,
         placeStore: PlaceCoreDataActions, persistenceController: PersistenceController,
         locationManager: LocationManager, coordinator: MainCoordinator,
         fileManager: LocalFileManager, settingsManager: SettingsManager) {
        self.weatherService = weatherService
        self.placesService = placesService
        self.placeStore = placeStore
        self.persistenceController = persistenceController
        self.locationManager = locationManager
        self.coordinator = coordinator
        self.fileManager = fileManager
        self.settingsManager = settingsManager
    }

    static func live() -> AppDependencies {
        let networkManager = NetworkManager()
        let apiKeyManager = ApiKeyManager()
        let persistenceController = PersistenceController.shared
        return AppDependencies(
            weatherService: WeatherService(networkManager: networkManager, apiKeyManager: apiKeyManager),
            placesService: PlacesService(networkManager: networkManager, apiKeyManager: apiKeyManager),
            placeStore: PlaceCoreDataManager(container: persistenceController.container),
            persistenceController: persistenceController, locationManager: LocationManager(),
            coordinator: MainCoordinator(), fileManager: LocalFileManager(), settingsManager: SettingsManager())
    }

    static func preview() -> AppDependencies {
        let persistenceController = PersistenceController(inMemory: true)
        let locationManager = LocationManager(startAutomatically: false)
        locationManager.locationAuthorized = true
        locationManager.currentLocation = CLLocation(latitude: 33.7488, longitude: -84.3877)
        return AppDependencies(
            weatherService: PreviewWeatherService(), placesService: PreviewPlacesService(),
            placeStore: PlaceCoreDataManager(container: persistenceController.container),
            persistenceController: persistenceController, locationManager: locationManager,
            coordinator: MainCoordinator(), fileManager: LocalFileManager(), settingsManager: SettingsManager())
    }

    func makeWeatherForecastViewModel() -> WeatherForecastViewModel {
        WeatherForecastViewModel(weatherService: weatherService, coreDataManager: placeStore)
    }

    func makeCurrentWeatherViewModel() -> CurrentWeatherForecastViewModel {
        CurrentWeatherForecastViewModel(weatherService: weatherService)
    }

    func makeLocationSearchViewModel() -> LocationForecastViewModel {
        LocationForecastViewModel(placesService: placesService)
    }

    func makeLocationsViewModel() -> LocationsViewModel {
        LocationsViewModel(placeCoreDataManager: placeStore)
    }
}

extension View {
    @MainActor
    func appEnvironment(_ dependencies: AppDependencies) -> some View {
        environmentObject(dependencies.locationManager)
            .environmentObject(dependencies.coordinator)
            .environmentObject(dependencies.fileManager)
            .environment(\.managedObjectContext, dependencies.persistenceController.container.viewContext)
    }
}

private struct PreviewWeatherService: WeatherServicing {
    func getForecast(coordinate: CLLocationCoordinate2D) async throws -> WeatherForecastData {
        WeatherForecastData(forecast: PreviewManager.oneCallResponse, geocode: PreviewManager.geocode)
    }

    func getCurrentWeather(coordinate: CLLocationCoordinate2D) async throws -> WeatherForecastCurrentResponse {
        let data = PreviewManager.weatherForecastData
        guard let forecast = data.list.first, let wind = forecast.wind, let clouds = forecast.clouds else {
            throw NetworkError.noData
        }
        return WeatherForecastCurrentResponse(
            id: data.city.id, dateTime: forecast.id,
            coordinate: WeatherForecastCoordinate(longitude: coordinate.longitude, latitude: coordinate.latitude),
            weather: forecast.weathers, main: forecast.main, visibility: forecast.visibility,
            wind: wind, clouds: clouds,
            system: System(type: 1, id: 1, sunrise: data.city.sunrise ?? 0,
                           sunset: data.city.sunset ?? 0, country: data.city.country),
            timezone: data.city.timezone ?? 0, name: data.city.name, cod: 200)
    }
}

private struct PreviewPlacesService: PlacesServicing {
    func getPredictions(query: String) async throws -> [Prediction] { PreviewManager.predictions }
    func getPlaceDetails(placeID: String) async throws -> GooglePlaceDetails { PreviewManager.placeDetails }
}
