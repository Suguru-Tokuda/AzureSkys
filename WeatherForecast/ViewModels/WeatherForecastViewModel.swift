//
//  WeatherForecastViewModel.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Foundation
import Combine
import MapKit

@MainActor
class WeatherForecastViewModel: ObservableObject {
    @Published var city: City?
    @Published var forecast: WeatherForecastOneCallResponse?
    @Published var geocode: WeatherGeocode?
    @Published var isLoading = false
    @Published var isErrorOccured = false
    @Published var customError: Error?
    @Published var locationAuthorized: Bool = false

    var currentLocation: CLLocation?
    var cancellables = Set<AnyCancellable>()
    
    var networkManager: Networking
    var coreDataManager: CityCoreDataActions
    var locationManager: LocationManager?
    
    init(networkManager: Networking = NetworkManager(), coreDataManager: CityCoreDataActions = CityCoreDataManager()) {
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
        
        self.getSQLitePath()
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
                .sink { receivedVal in
                    self.locationAuthorized = receivedVal.0
                    let callApi: Bool = self.currentLocation == nil
                    self.currentLocation = receivedVal.1
                    
                    Task {
                        if callApi { await self.getWeatherForecastData() }
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    /**
     Get weather forecast & geo location with the current location
     */
    func getWeatherForecastData() async {
        if let _ = currentLocation,
           !isLoading {
            guard let forecastUrl = URL(string: getWeatherForecastOnecallAPIString()),
                  let geocodeUrl = URL(string: getGeocodeAPIString()) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
            isLoading = true
            
            do {
                async let forecast = networkManager.getDataWithAsync(url: forecastUrl, type: WeatherForecastOneCallResponse.self)
                async let geocode = networkManager.getDataWithAsync(url: geocodeUrl, type: [WeatherGeocode].self)
                
                let res: [Any] = try await [forecast, geocode]
                
                if let forecastRes = res[0] as? WeatherForecastOneCallResponse {
                    self.forecast = forecastRes
                }
                
                if let geocodeRes = res[1] as? [WeatherGeocode],
                   let geocode = geocodeRes.first {
                    self.geocode = geocode
                }
                                
                self.isLoading = false
            } catch {
                self.isLoading = false
                await handleGetWeatherForecastError(error: error)
            }
        }
    }
    
    /**
        Get weather forecast & geo location with the city data
     */
    func getWeatherForecastData(city: City) async {
        if !isLoading {
            guard let forecastUrl = URL(string: getWeatherForecastOnecallAPIString(city: city)),
                  let geocodeUrl = URL(string: getGeocodeAPIString(city: city)) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
            self.isLoading = true
            
            do {
                async let forecast = networkManager.getDataWithAsync(url: forecastUrl, type: WeatherForecastOneCallResponse.self)
                async let geocode = networkManager.getDataWithAsync(url: geocodeUrl, type: [WeatherGeocode].self)
                
                let res: [Any] = try await [forecast, geocode]
                
                if let forecastRes = res[0] as? WeatherForecastOneCallResponse {
                    self.forecast = forecastRes
                }
                
                if let geocodeRes = res[1] as? [WeatherGeocode],
                   let geocode = geocodeRes.first {
                    self.geocode = geocode
                }
                
                self.isLoading = false
            } catch {
                self.isLoading = false
                await handleGetWeatherForecastError(error: error)
            }
        }
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
        Dependency injection for locationManager
     */
    func setLocationManager(locationManager: LocationManager) {
        self.locationManager = locationManager
        self.cancellables.removeAll()
        self.addLocationSubscriptions()
    }
    
    func addCity(city: City?, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        if let city {
            Task {
                do {
                    try await coreDataManager.saveCityIntoDatabase(city: city)
                    completionHandler(.success(true))
                } catch {
                    self.isErrorOccured = true
                    self.customError = CoreDataError.save
                    
                    completionHandler(.failure(error))
                }
            }
        }
    }
    
    /**
        Get url by using the current location
     */
    private func getWeatherForecastOnecallAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = ApiKeys.weatherApiKey) -> String {
        guard let currentLocation else { return "" }
        return "\(urlString)/data/3.0/onecall?lat=\(currentLocation.coordinate.latitude)&lon=\(currentLocation.coordinate.longitude)&exclude=minutely&appid=\(apiKey)"
    }
    
    /**
        Get url by using City data.
     */
    private func getWeatherForecastOnecallAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = ApiKeys.weatherApiKey, city: City) -> String {
        return "\(urlString)/data/3.0/onecall?lat=\(city.coordinate.lat)&lon=\(city.coordinate.lon)&exclude=minutely&appid=\(apiKey)"
    }
    
    /**
        Get geocode url by current location
     */
    private func getGeocodeAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = ApiKeys.weatherApiKey) -> String {
        guard let currentLocation else { return "" }
        return "\(urlString)/geo/1.0/reverse?lat=\(currentLocation.coordinate.latitude)&lon=\(currentLocation.coordinate.longitude)&appid=\(apiKey)"
    }
    
    /**
        Get geocode url by city
     */
    private func getGeocodeAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = ApiKeys.weatherApiKey, city: City) -> String {
        return "\(urlString)/geo/1.0/reverse?lat=\(city.coordinate.lat)&lon=\(city.coordinate.lon)&appid=\(apiKey)"
    }
    
    func getSQLitePath() {
        // .shared, .default, .standard - same thing
        guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        
        let sqlitePath = url.appendingPathComponent("WeatherCoreData")
        print(sqlitePath.absoluteString)
    }
}
