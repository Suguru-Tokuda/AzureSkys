//
//  WeatherForecastViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//

import SwiftUI
import Combine
import MapKit

@MainActor
@Observable
class WeatherForecastViewModel {
    private(set) var showForecastAnimation = true
    private(set) var locationAuthorized: Bool?
    private(set) var coreDataError: CoreDataError?
    var forecast: WeatherForecastOneCallResponse? { requestState.value?.forecast }
    var geocode: WeatherGeocode? { requestState.value?.geocode }
    var networkError: NetworkError? { requestState.error }
    var loadingStatus: LoadingStatus { requestState.loadingStatus }
    private var requestState: RequestState<WeatherForecastData> = .idle
    @ObservationIgnored private(set) var place: SavedPlace?
    @ObservationIgnored private(set) var currentLocation: CLLocation?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var wasInactive = false
    @ObservationIgnored var locationManager: LocationManager?
    private let weatherService: WeatherServicing
    private let coreDataManager: PlaceCoreDataActions

    func didBecomeActive() {
        guard wasInactive else { return }

        wasInactive = false
        startDataRefreshTimer(showLoading: false)
    }

    func willResignActive() {
        wasInactive = true
        endDataRefreshTimer()
    }

    private let refreshScheduler = RefreshScheduler()

    init(
        weatherService: WeatherServicing,
        coreDataManager: PlaceCoreDataActions
    ) {
        self.weatherService = weatherService
        self.coreDataManager = coreDataManager
    }

    /**
        Adds subscription for the current location from the locationManager
     */
    func addLocationSubscriptions() {
        if let locationManager {
            locationManager.$locationAuthorized
                .combineLatest(locationManager.$currentLocation)
                .receive(on: RunLoop.main)
                .sink { [weak self] receivedVal in
                    guard let self else { return }

                    self.locationAuthorized = receivedVal.0

                    let callApi = self.currentLocation == nil && receivedVal.1 != nil

                    self.currentLocation = receivedVal.1

                    if callApi && refreshScheduler.isRunning {
                        startDataRefreshTimer()
                    }
                }
                .store(in: &cancellables)
        }
    }

    func getWeatherForecastData(showLoading: Bool = true) async {
        guard let currentLocation else { return }

        await getWeatherForecastData(coordinate: currentLocation.coordinate, showLoading: showLoading)
    }

    func getWeatherForecastData(place: SavedPlace, showLoading: Bool = true) async {
        let coordinate = CLLocationCoordinate2D(
            latitude: place.latitude,
            longitude: place.longitude
        )
        await getWeatherForecastData(coordinate: coordinate, showLoading: showLoading)
    }

    private func getWeatherForecastData(coordinate: CLLocationCoordinate2D, showLoading: Bool) async {
        guard !Task.isCancelled else {
            return
        }

        if case .loading = requestState {
            return
        }

        let previous = requestState.value

        requestState = .loading(previous: showLoading ? nil : previous)

        do {
            let data = try await weatherService.getForecast(coordinate: coordinate)

            try Task.checkCancellation()
            requestState = .loaded(data)
        } catch {
            guard !Task.isCancelled else {
                requestState = previous.map(RequestState.loaded) ?? .idle

                return
            }

            requestState = .failed(NetworkError(error), previous: previous)
        }
    }

    func loadWeatherData(showLoading: Bool) async {
        if let place {
            await self.getWeatherForecastData(place: place, showLoading: showLoading)
        } else {
            await self.getWeatherForecastData(showLoading: showLoading)
        }
    }

    func dismissError() {
        coreDataError = nil
    }

    /**
        Dependency injection for locationManager
     */
    func setLocationManager(locationManager: LocationManager) {
        self.locationManager = locationManager
        self.cancellables.removeAll()
        self.addLocationSubscriptions()
    }

    func addPlace(place: SavedPlace?, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        if let place {
            Task { [weak self] in
                guard let self else { return }

                do {
                    coreDataError = nil
                    try await coreDataManager.savePlaceIntoDatabase(place: place)
                    completionHandler(.success(true))
                } catch {
                    self.coreDataError = CoreDataError.save

                    completionHandler(.failure(error))
                }
            }
        }
    }

}

// MARK: Refresh scheduling

extension WeatherForecastViewModel {
    func setPlace(place: SavedPlace? = nil) {
        self.place = place
    }

    func startDataRefreshTimer(showLoading: Bool = true) {
        refreshScheduler.start(showLoading: showLoading) { [weak self] showLoading in
            self?.showForecastAnimation = showLoading
            await self?.loadWeatherData(showLoading: showLoading)
        }
    }

    func endDataRefreshTimer() {
        refreshScheduler.stop()
    }
}

// MARK: Test hooks

#if DEBUG
extension WeatherForecastViewModel {
    /// Exposes private state to unit tests without widening its access level.
    @MainActor
    struct TestHooks {
        fileprivate let target: WeatherForecastViewModel

        var requestState: RequestState<WeatherForecastData> { target.requestState }
        var subscriptionCount: Int { target.cancellables.count }

        func setCurrentLocation(_ location: CLLocation?) {
            target.currentLocation = location
        }
    }

    var testHooks: TestHooks { TestHooks(target: self) }
}
#endif
