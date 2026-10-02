//
//  CurrentWeatherForecastViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import Combine
import MapKit
import SwiftUI

@MainActor
class CurrentWeatherForecastViewModel: ObservableObject {
    @Published var currentForecast: WeatherForecastCurrentResponse?
    @Published var loadingStatus: LoadingStatus = .inactive
    @Published var hasError = false
    @Published var customError: NetworkError?
    @Published var locationAuthorized: Bool?
    @Published var listRowBackground: LinearGradient = .init(gradient: Gradient(colors: [Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
    var place: GooglePlaceDetails?
    
    var currentLocation: CLLocation?
    var cancellables = Set<AnyCancellable>()

    private let weatherService: WeatherServicing
    var locationManager: LocationManager?

    private let refreshScheduler = RefreshScheduler()
    private var isFetching = false

    init(weatherService: WeatherServicing) {
        self.weatherService = weatherService
    }

    deinit {
        self.cancellables.removeAll()
    }

    func setLocationManager(locationManager: LocationManager) {
        self.locationManager = locationManager
        self.cancellables.removeAll()
        self.addLocationSubscriptions()
    }

    func setPlace(place: GooglePlaceDetails) {
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
        let coordinate = CLLocationCoordinate2D(latitude: place.geometry.location.latitude,
                                                longitude: place.geometry.location.longitude)
        await getCurrentWeatherData(coordinate: coordinate, showLoading: showLoading)
    }

    private func getCurrentWeatherData(coordinate: CLLocationCoordinate2D, showLoading: Bool) async {
        guard !isFetching, !Task.isCancelled else { return }
        isFetching = true
        defer { isFetching = false }
        if showLoading {
            loadingStatus = .loading
        }

        do {
            let response = try await weatherService.getCurrentWeather(coordinate: coordinate)
            try Task.checkCancellation()
            currentForecast = response
            if let weather = response.weather.first {
                setRowBackgroundColor(weather: weather, clouds: response.clouds.all)
            }
            loadingStatus = .loaded
            customError = nil
            hasError = false
        } catch {
            loadingStatus = .inactive
            guard !Task.isCancelled else { return }
            await handleGetWeatherForecastError(error: error)
        }
    }

    func loadCurrentWeatherData(showLoading: Bool) async {
        if place != nil {
            await getCurrentWeatherDataWithCityData(showLoading: showLoading)
        } else {
            await getCurrentWeatherDataWithCurrentLocation(showLoading: showLoading)
        }
    }
    
    private func setRowBackgroundColor(weather: Weather, clouds: Int) {
        self.listRowBackground = weather.weatherCondition.getBackgroundColor(partOfDay: weather.partOfDay, clouds: clouds)
    }
    
    private func handleGetWeatherForecastError(error: Error) async {
        switch error {
        case NetworkError.badUrl:
            customError = NetworkError.badUrl
        case NetworkError.dataParsingError:
            customError = NetworkError.dataParsingError
        case NetworkError.noData:
            customError = NetworkError.noData
        case NetworkError.serverError:
            customError = NetworkError.serverError
        case NetworkError.unknown:
            customError = NetworkError.unknown
        default:
            customError = NetworkError.unknown
        }
        
        hasError = true
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
