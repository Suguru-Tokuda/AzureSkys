//
//  WeatherForecastViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Foundation
import SwiftUI
import Combine
import MapKit

@MainActor
class WeatherForecastViewModel: ObservableObject {
    @Published var showForecastAnimation = true
    @Published var forecast: WeatherForecastOneCallResponse?
    @Published var geocode: WeatherGeocode?
    @Published var loadingStatus: LoadingStatus = .inactive
    @Published var hasError = false
    @Published var networkError: NetworkError?
    @Published var coreDataError: CoreDataError?
    @Published var locationAuthorized: Bool?
    @Published var background: LinearGradient = LinearGradient(colors: [Color.clear], 
                                                               startPoint: .topLeading,
                                                               endPoint: .bottomTrailing)
    var place: SavedPlace?
    var currentLocation: CLLocation?
    var cancellables = Set<AnyCancellable>()
    
    private let weatherService: WeatherServicing
    private let coreDataManager: PlaceCoreDataActions
    var locationManager: LocationManager?
    private let refreshScheduler = RefreshScheduler()
    private var isFetching = false

    init(weatherService: WeatherServicing,
         coreDataManager: PlaceCoreDataActions) {
        self.weatherService = weatherService
        self.coreDataManager = coreDataManager
    }

    deinit {
        self.cancellables.removeAll()
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
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude,
                                                longitude: place.longitude)
        await getWeatherForecastData(coordinate: coordinate, showLoading: showLoading)
    }

    private func getWeatherForecastData(coordinate: CLLocationCoordinate2D, showLoading: Bool) async {
        guard !isFetching, !Task.isCancelled else { return }
        isFetching = true
        defer { isFetching = false }
        if showLoading {
            loadingStatus = .loading
        }

        do {
            let data = try await weatherService.getForecast(coordinate: coordinate)
            try Task.checkCancellation()
            self.forecast = data.forecast
            self.geocode = data.geocode
            setBackgroundColor()
            loadingStatus = .loaded
            networkError = nil
            hasError = coreDataError != nil
        } catch {
            loadingStatus = .inactive
            guard !Task.isCancelled else { return }
            await handleGetWeatherForecastError(error: error)
        }
    }

    func loadWeatherData(showLoading: Bool) async {
        if let place {
            await self.getWeatherForecastData(place: place, showLoading: showLoading)
        } else {
            await self.getWeatherForecastData(showLoading: showLoading)
        }
    }
    
    func dismissError<T: LocalizedError>(error: T?) {
        if let error {
            if error is NetworkError {
                self.networkError = nil
            }
            
            if error is CoreDataError {
                self.coreDataError = nil
            }
        }
        
        hasError = false
    }
    
    private func handleGetWeatherForecastError(error: Error) async {
        switch error {
        case NetworkError.badUrl:
            networkError = NetworkError.badUrl
        case NetworkError.dataParsingError:
            networkError = NetworkError.dataParsingError
        case NetworkError.noData:
            networkError = NetworkError.noData
        case NetworkError.serverError:
            networkError = NetworkError.serverError
        case NetworkError.networkUnavailable:
            networkError = .networkUnavailable
        case NetworkError.unknown:
            networkError = NetworkError.unknown
        default:
            networkError = NetworkError.unknown
        }

        hasError = true
    }
    
    private func setBackgroundColor() {
        if let forecast,
           let weather = forecast.current.weather.first {
            self.background = weather.weatherCondition.getBackgroundColor(partOfDay: weather.partOfDay, clouds: forecast.current.clouds ?? 0)
        }
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
                    try await coreDataManager.savePlaceIntoDatabase(place: place)
                    completionHandler(.success(true))
                } catch {
                    self.hasError = true
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
