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
    @Published var isErrorOccured = false
    @Published var customError: NetworkError?
    @Published var locationAuthorized: Bool?
    @Published var listRowBackground: LinearGradient = .init(gradient: Gradient(colors: [Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
    var place: GooglePlaceDetails?
    
    var currentLocation: CLLocation?
    var cancellables = Set<AnyCancellable>()

    var networkManager: Networking
    var apiKeyManager: ApiKeyActions
    var locationManager: LocationManager?

    private let refreshScheduler = RefreshScheduler()
    private var isFetching = false

    init(networkManager: Networking = NetworkManager(), apiKeyManager: ApiKeyActions = ApiKeyManager()) {
        self.networkManager = networkManager
        self.apiKeyManager = apiKeyManager
        
        self.networkManager.checkNetworkAvailability(queue: DispatchQueue.global(qos: .background)) { [weak self] networkAvailable in
            guard let self else { return }
            DispatchQueue.main.async {
                self.customError = !networkAvailable ? NetworkError.networkUnavailable : nil
            }
        }
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

    func getCurrentWeatherDataWithCurrentLocation(urlString: String = Constants.weatherApiEndpoint, showLoading: Bool = true) async {
        if let currentLocation,
           !isFetching, !Task.isCancelled {
            isFetching = true
            defer { isFetching = false }
            
            guard let urlStr = getCurrentWeatherForecastAPIString(urlString: urlString, coordinate: currentLocation.coordinate),
                  let url = URL(string: urlStr) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }

            if showLoading {
                loadingStatus = .loading
            }
            
            do {
                let response = try await networkManager.getData(url: url, type: WeatherForecastCurrentResponse.self)
                try Task.checkCancellation()
                self.currentForecast = response
                if let currentForecast = self.currentForecast,
                   let weather = currentForecast.weather.first {
                    self.setRowBackgroundColor(weather: weather, clouds: currentForecast.clouds.all)
                }
                
                self.loadingStatus = .loaded
                self.customError = nil
                self.isErrorOccured = false
            } catch {
                self.loadingStatus = .inactive
                guard !Task.isCancelled else { return }
                await handleGetWeatherForecastError(error: error)
            }
        }
    }
    
    func getCurrentWeatherDataWithCityData(urlString: String = Constants.weatherApiEndpoint, showLoading: Bool = true) async {
        if let place,
           !isFetching, !Task.isCancelled {
            isFetching = true
            defer { isFetching = false }
            guard let urlStr = getCurrentWeatherForecastAPIString(coordinate: CLLocationCoordinate2D(latitude: place.geometry.location.latitude, longitude: place.geometry.location.longitude)),
                  let url = URL(string: urlStr) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }

            if showLoading {
                loadingStatus = .loading
            }
            
            do {
                let response = try await networkManager.getData(url: url, type: WeatherForecastCurrentResponse.self)
                try Task.checkCancellation()
                self.currentForecast = response
                if let currentForecast = self.currentForecast,
                   let weather = currentForecast.weather.first {
                    self.setRowBackgroundColor(weather: weather, clouds: currentForecast.clouds.all)
                }
                self.loadingStatus = .loaded
                self.customError = nil
                self.isErrorOccured = false
            } catch {
                self.loadingStatus = .inactive
                guard !Task.isCancelled else { return }
                await handleGetWeatherForecastError(error: error)
            }
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
        self.listRowBackground = weather.weatherCondition.getBackGroundColor(partOfDay: weather.partOfDay, clouds: clouds)
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
        
        isErrorOccured = true
    }
    
    /**
        Get url for current by coordinate
     */
    private func getCurrentWeatherForecastAPIString(urlString: String = Constants.weatherApiEndpoint,
                                                    coordinate: CLLocationCoordinate2D) -> String? {
        do {
            let apiKey = try apiKeyManager.getOpenWeatherApiKey()
            return "\(urlString)/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)"
        } catch {
            return nil
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
