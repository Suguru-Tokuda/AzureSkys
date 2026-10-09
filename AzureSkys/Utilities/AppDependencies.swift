//
//  AppDependencies.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/1/26.
//

import SwiftUI
import Combine
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
    private var syncRestoreSubscription: AnyCancellable?
    let iCloudManager: ICloudManaging

    init(weatherService: WeatherServicing, placesService: PlacesServicing,
         placeStore: PlaceCoreDataActions, persistenceController: PersistenceController,
         locationManager: LocationManager, coordinator: MainCoordinator,
         fileManager: LocalFileManager, settingsManager: SettingsManager, iCloudManager: ICloudManaging
    ) {
        self.weatherService = weatherService
        self.placesService = placesService
        self.placeStore = placeStore
        self.persistenceController = persistenceController
        self.locationManager = locationManager
        self.coordinator = coordinator
        self.fileManager = fileManager
        self.settingsManager = settingsManager
        self.iCloudManager = iCloudManager
    }

    static func live() -> AppDependencies {
        let networkManager = NetworkManager()
        let apiKeyManager = ApiKeyManager()
        let persistenceController = PersistenceController(syncEnabled: syncEnabled)
        let iCloudManager = ICloudManager(persistence: persistenceController)
        Task {
            do { try await iCloudManager.restoreSyncAfterReinstall() }
            catch { persistenceController.reportSyncError(error) }
        }
        let dependencies = AppDependencies(
            weatherService: WeatherService(networkManager: networkManager, apiKeyManager: apiKeyManager),
            placesService: PlacesService(networkManager: networkManager, apiKeyManager: apiKeyManager),
            placeStore: PlaceCoreDataManager(persistence: persistenceController),
            persistenceController: persistenceController, locationManager: LocationManager(),
            coordinator: MainCoordinator(), fileManager: LocalFileManager(), settingsManager: SettingsManager(),
            iCloudManager: iCloudManager)
        dependencies.syncRestoreSubscription = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .merge(with: NotificationCenter.default.publisher(for: .CKAccountChanged))
            .sink { _ in
                Task { @MainActor in
                    do { try await iCloudManager.restoreSyncAfterReinstall() }
                    catch { persistenceController.reportSyncError(error) }
                }
            }
        return dependencies
    }

    static func preview(placesService: PlacesServicing? = nil) -> AppDependencies {
        let persistenceController = PersistenceController(inMemory: true)
        let locationManager = LocationManager(startAutomatically: false)
        locationManager.locationAuthorized = true
        locationManager.currentLocation = CLLocation(latitude: 33.7488, longitude: -84.3877)
        return AppDependencies(
            weatherService: PreviewWeatherService(), placesService: placesService ?? PreviewPlacesService(),
            placeStore: PlaceCoreDataManager(persistence: persistenceController),
            persistenceController: persistenceController, locationManager: locationManager,
            coordinator: MainCoordinator(), fileManager: LocalFileManager(), settingsManager: SettingsManager(),
            iCloudManager: PreviewICloudManager())
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(locationManager: locationManager, iCloudManager: iCloudManager)
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

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(iCloudManager: iCloudManager)
    }

    private static var syncEnabled: Bool {
        UserDefaults.standard.bool(
            forKey: UserDefaultKeys.iCloudSyncEnabled.rawValue
        )
    }
}

private struct AppEnvironmentModifier: ViewModifier {
    let dependencies: AppDependencies
    @ObservedObject var persistence: PersistenceController

    func body(content: Content) -> some View {
        content
            .environmentObject(dependencies.locationManager)
            .environmentObject(dependencies.coordinator)
            .environmentObject(dependencies.fileManager)
            .environment(\.managedObjectContext, persistence.viewContext)
    }
}

extension View {
    @MainActor
    func appEnvironment(_ dependencies: AppDependencies) -> some View {
        modifier(AppEnvironmentModifier(
            dependencies: dependencies,
            persistence: dependencies.persistenceController
        ))
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
    func getPlaceDetails(placeID: String) async throws -> SavedPlace { SavedPlace(details: PreviewManager.placeDetails) }
}

private struct PreviewICloudManager: ICloudManaging {
    func isAvailable() async throws -> Bool { false }
    func setEnabled(_ enabled: Bool) async throws {}
}

#if DEBUG
extension AppDependencies {
    static func uiTesting() -> AppDependencies {
        preview(placesService: UITestPlacesService())
    }
}

private final class UITestPlacesService: PlacesServicing {
    private var failedSearch = false

    func getPredictions(query: String) async throws -> [Prediction] {
        if ProcessInfo.processInfo.arguments.contains(LaunchArguments.searchFailsOnceArgument), !failedSearch {
            failedSearch = true
            throw NetworkError.networkUnavailable
        }
        return Array(PreviewManager.predictions.prefix(1))
    }

    func getPlaceDetails(placeID: String) async throws -> SavedPlace {
        SavedPlace(details: PreviewManager.placeDetails)
    }
}
#endif
