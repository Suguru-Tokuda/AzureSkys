//
//  WeatherForecastViewModel.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Foundation
import SwiftUI
import Combine
import MapKit

@MainActor
class WeatherForecastViewModel: ObservableObject {
    @Published var city: City?
    @Published var forecast: WeatherForecastOneCallResponse?
    @Published var geocode: WeatherGeocode?
    @Published var loadingStatus: LoadingStatus = .inactive
    @Published var isErrorOccured = false
    @Published var networkError: NetworkError?
    @Published var coreDataError: CoreDataError?
    @Published var locationAuthorized: Bool?
    @Published var background: LinearGradient = LinearGradient(colors: [Color.clear], 
                                                               startPoint: .topLeading,
                                                               endPoint: .bottomTrailing)
    var place: GooglePlaceDetails?
    var currentLocation: CLLocation?
    var cancellables = Set<AnyCancellable>()
    
    var networkManager: Networking
    var coreDataManager: PlaceCoreDataActions
    var apiKeyManager: ApiKeyActions
    var locationManager: LocationManager?
    let refreshInterval: Double = 300 // 5 mins
    var refreshCount: Int = 0
    var dataRefreshTimer: Timer?
    
    init(networkManager: Networking = NetworkManager(), 
         coreDataManager: PlaceCoreDataActions = PlaceCoreDataManager(),
         apiKeyManager: ApiKeyActions = ApiKeyManager()) {
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
        self.apiKeyManager = apiKeyManager
        
        self.getSQLitePath()
        
        self.networkManager.checkNetworkAvailability(queue: DispatchQueue.global(qos: .background)) { [weak self] networkAvailable in
            guard let self else { return }
            DispatchQueue.main.async {
                self.networkError = !networkAvailable ? .networkUnavailable : nil
            }
        }
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
                    let callApi: Bool = self.currentLocation == nil
                    self.currentLocation = receivedVal.1

                    if callApi {
                        startDataRefreshTimer()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    /**
     Get weather forecast & geo location with the current location
     */
    func getWeatherForecastData(showLoading: Bool = true) async {
        if let _ = currentLocation,
           loadingStatus != .loading {
            guard let forecastUrlStr = getWeatherForecastOnecallAPIString(),
                  let geocodeUrlStr = getGeocodeAPIString(),
                  let forecastUrl = URL(string: forecastUrlStr),
                  let geocodeUrl = URL(string: geocodeUrlStr) else {
                isErrorOccured = true
                networkError = NetworkError.badUrl
                return
            }
            
            if showLoading {
                loadingStatus = .loading
            }
            
            do {
                async let forecast = networkManager.getData(url: forecastUrl, type: WeatherForecastOneCallResponse.self)
                async let geocode = networkManager.getData(url: geocodeUrl, type: [WeatherGeocode].self)
                
                let res: [Any] = try await [forecast, geocode]
                
                if let forecastRes = res[0] as? WeatherForecastOneCallResponse {
                    self.forecast = forecastRes
                    self.setBackgroundColor()
                }
                
                if let geocodeRes = res[1] as? [WeatherGeocode],
                   let geocode = geocodeRes.first {
                    self.geocode = geocode
                }
                                
                self.loadingStatus = .loaded
                self.isErrorOccured = false
                self.networkError = nil
            } catch {
                self.loadingStatus = .inactive
                await handleGetWeatherForecastError(error: error)
            }
        }
    }
    
    /**
        Get weather forecast & geo location with the city data
     */
    func getWeatherForecastData(place: GooglePlaceDetails, showLoading: Bool = true) async {
        if loadingStatus != .loading {
            guard let forecastUrlStr = getWeatherForecastOnecallAPIString(place: place),
                  let geocodeUrlStr = getGeocodeAPIString(place: place),
                  let forecastUrl = URL(string: forecastUrlStr),
                  let geocodeUrl = URL(string: geocodeUrlStr) else {
                isErrorOccured = true
                networkError = NetworkError.badUrl
                return
            }
            
            if showLoading {
                self.loadingStatus = .loading
            }
            
            do {
                async let forecast = networkManager.getData(url: forecastUrl, type: WeatherForecastOneCallResponse.self)
                async let geocode = networkManager.getData(url: geocodeUrl, type: [WeatherGeocode].self)

                let res: [Any] = try await [forecast, geocode]
                
                if let forecastRes = res[0] as? WeatherForecastOneCallResponse {
                    self.forecast = forecastRes
                    self.setBackgroundColor()
                }
                
                if let geocodeRes = res[1] as? [WeatherGeocode],
                   let geocode = geocodeRes.first {
                    self.geocode = geocode
                }
                
                self.loadingStatus = .loaded
            } catch {
                self.loadingStatus = .inactive
                await handleGetWeatherForecastError(error: error)
            }
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
        
        isErrorOccured = false
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
        case NetworkError.unknown:
            networkError = NetworkError.unknown
        default:
            networkError = NetworkError.unknown
        }

        if let dataRefreshTimer {
            dataRefreshTimer.invalidate()
            self.dataRefreshTimer = nil
        }

        isErrorOccured = true
    }
    
    private func setBackgroundColor() {
        if let forecast,
           let weather = forecast.current.weather.first {
            self.background = weather.weatherCondition.getBackGroundColor(partOfDay: weather.partOfDay)
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
    
    func addPlace(place: GooglePlaceDetails?, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        if let place {
            Task {
                do {
                    try await coreDataManager.savePlaceIntoDatabase(place: place)
                    completionHandler(.success(true))
                } catch {
                    self.isErrorOccured = true
                    self.coreDataError = CoreDataError.save
                    
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    /**
        Get url by using the current location
     */
    private func getWeatherForecastOnecallAPIString(urlString: String = Constants.weatherApiEndpoint) -> String? {
        guard let currentLocation,
              let apiKey = try? apiKeyManager.getOpenWeatherApiKey() else { return nil }
        return "\(urlString)/data/3.0/onecall?lat=\(currentLocation.coordinate.latitude)&lon=\(currentLocation.coordinate.longitude)&exclude=minutely&appid=\(apiKey)"
    }
    
    /**
        Get url by using City data.
     */
    private func getWeatherForecastOnecallAPIString(urlString: String = Constants.weatherApiEndpoint, place: GooglePlaceDetails) -> String? {
        guard let apiKey = try? apiKeyManager.getOpenWeatherApiKey() else { return nil }
        return "\(urlString)/data/3.0/onecall?lat=\(place.geometry.location.latitude)&lon=\(place.geometry.location.longitude)&exclude=minutely&appid=\(apiKey)"
    }
    
    /**
        Get geocode url by current location
     */
    private func getGeocodeAPIString(urlString: String = Constants.weatherApiEndpoint) -> String? {
        guard let currentLocation,
              let apiKey = try? apiKeyManager.getOpenWeatherApiKey() else { return nil }
        return "\(urlString)/geo/1.0/reverse?lat=\(currentLocation.coordinate.latitude)&lon=\(currentLocation.coordinate.longitude)&appid=\(apiKey)"
    }
    
    /**
        Get geocode url by city
     */
    private func getGeocodeAPIString(urlString: String = Constants.weatherApiEndpoint, place: GooglePlaceDetails) -> String? {
        guard let apiKey = try? apiKeyManager.getOpenWeatherApiKey() else { return nil }
        return "\(urlString)/geo/1.0/reverse?lat=\(place.geometry.location.latitude)&lon=\(place.geometry.location.longitude)&appid=\(apiKey)"
    }
    
    func getSQLitePath() {
        // .shared, .default, .standard - same thing
//        guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
//            return
//        }
        
        // let sqlitePath = url.appendingPathComponent("WeatherCoreData")
    }
}

// MARK: Refresh scheduling

extension WeatherForecastViewModel {
    private func resetRefreshCount() {
        self.refreshCount = 0
    }

    private func incrementRefreshCount() async  {
        self.refreshCount += 1
    }

    func setPlace(place: GooglePlaceDetails? = nil) {
        self.place = place
    }

    func startDataRefreshTimer() {
        endDataRefreshTimer()
        
        Task(priority: .utility) {
            await self.loadWeatherData(showLoading: self.refreshCount == 0)
            await self.incrementRefreshCount()
        }

        dataRefreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval,
                                                repeats: true) { _ in
            Task(priority: .utility) {
                await self.incrementRefreshCount()
                await self.loadWeatherData(showLoading: self.refreshCount == 0)
            }
        }
    }

    func endDataRefreshTimer() {
        if let dataRefreshTimer {
            dataRefreshTimer.invalidate()
            self.dataRefreshTimer = nil
            self.resetRefreshCount()
        }
    }
}
