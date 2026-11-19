//
//  CurrentWeatherForecastViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import Combine
import MapKit
import Observation
import SwiftUI

@MainActor
@Observable
class CurrentWeatherForecastViewModel {
    var currentForecast: WeatherForecastCurrentResponse? { requestState.value }
    var loadingStatus: LoadingStatus { requestState.loadingStatus }
    private let weatherService: WeatherServicing
    private var requestState: RequestState<WeatherForecastCurrentResponse> = .idle
    private let refreshScheduler = RefreshScheduler()

    @ObservationIgnored var place: SavedPlace?
    @ObservationIgnored private var currentLocation: CLLocation?
    @ObservationIgnored private var locationAuthorized: Bool?
    @ObservationIgnored private var locationManager: LocationManager?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var wasInactive = false

    func didBecomeActive() {
        guard wasInactive else { return }

        wasInactive = false
        startDataRefreshTimer(showLoading: false)
    }

    func willResignActive() {
        wasInactive = true
        endDataRefreshTimer()
    }

    init(weatherService: WeatherServicing) {
        self.weatherService = weatherService
    }

    func setLocationManager(locationManager: LocationManager) {
        self.locationManager = locationManager
        self.cancellables.removeAll()
        self.addLocationSubscriptions()
    }

    func setPlace(place: SavedPlace) {
        self.place = place
    }

    func addLocationSubscriptions() {
        if let locationManager {
            locationManager.$locationAuthorized
                .combineLatest(locationManager.$currentLocation)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] receiveVal in
                    guard let self else { return }

                    locationAuthorized = receiveVal.0

                    let receivedFirstLocation = currentLocation == nil && receiveVal.1 != nil

                    currentLocation = receiveVal.1

                    if receivedFirstLocation && refreshScheduler.isRunning {
                        startDataRefreshTimer()
                    }
                }
                .store(in: &cancellables)
        }
    }

    func getCurrentWeatherDataWithCurrentLocation(showLoading: Bool = true) async {
        guard let currentLocation else { return }

        await getCurrentWeatherData(coordinate: currentLocation.coordinate, showLoading: showLoading)
    }

    func getCurrentWeatherDataWithCityData(showLoading: Bool = true) async {
        guard let place else { return }

        let coordinate = CLLocationCoordinate2D(
            latitude: place.latitude,
            longitude: place.longitude
        )
        await getCurrentWeatherData(coordinate: coordinate, showLoading: showLoading)
    }

    private func getCurrentWeatherData(coordinate: CLLocationCoordinate2D, showLoading: Bool) async {
        guard !Task.isCancelled else {
            return
        }

        if case .loading = requestState {
            return
        }

        let previous = requestState.value

        requestState = .loading(previous: showLoading ? nil : previous)

        do {
            let response = try await weatherService.getCurrentWeather(coordinate: coordinate)

            try Task.checkCancellation()
            requestState = .loaded(response)
        } catch {
            guard !Task.isCancelled else {
                requestState = previous.map(RequestState.loaded) ?? .idle

                return
            }

            requestState = .failed(NetworkError(error), previous: previous)
        }
    }

    func loadCurrentWeatherData(showLoading: Bool) async {
        if place != nil {
            await getCurrentWeatherDataWithCityData(showLoading: showLoading)
        } else {
            await getCurrentWeatherDataWithCurrentLocation(showLoading: showLoading)
        }
    }

}

// MARK: Refresh scheduling

extension CurrentWeatherForecastViewModel {
    func startDataRefreshTimer(showLoading: Bool = true) {
        refreshScheduler.start(showLoading: showLoading) { [weak self] showLoading in
            await self?.loadCurrentWeatherData(showLoading: showLoading)
        }
    }

    func endDataRefreshTimer() {
        refreshScheduler.stop()
    }
}

// MARK: Test hooks

#if DEBUG
extension CurrentWeatherForecastViewModel {
    /// Exposes private state to unit tests without widening its access level.
    @MainActor
    struct TestHooks {
        fileprivate let target: CurrentWeatherForecastViewModel

        var requestState: RequestState<WeatherForecastCurrentResponse> { target.requestState }
        var locationAuthorized: Bool? { target.locationAuthorized }
        var subscriptionCount: Int { target.cancellables.count }

        func setCurrentLocation(_ location: CLLocation?) {
            target.currentLocation = location
        }
    }

    var testHooks: TestHooks { TestHooks(target: self) }
}
#endif
