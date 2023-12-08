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
    @Published var fiveDayForecast: [WeatherForecast] = []
    @Published var weatherList: [WeatherForecast] = []
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
                        if callApi { await self.getWeatherForecasetData() }
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    /**
        Get weather forecast data with the user's current location.
     */
    func getWeatherForecasetData(urlString: String = Constants.weatherApiEndpoint) async {
        if let _ = currentLocation,
           !isLoading {
            guard let url = URL(string: getWeatherForecastAPIString(urlString: urlString)) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
            print(url.absoluteString)
            
            isLoading = true
            
            do {
                let res = try await networkManager.getDataWithAsync(url: url, type: WeatherForecastResponse.self)
                self.weatherList = res.list
                self.city = res.city
                self.fiveDayForecast = res.getDailyForecast()
                self.isLoading = false
            } catch {
                await handleGetWeatherForecasetError(error: error)
            }
        }
    }
    
    /**
        Get weather forecast data by using City data.
     */
    func getWeatherForecasetData(city: City) async {
        if !isLoading {
            guard let url = URL(string: getWeatherForecaseAPIString(city: city)) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
            print(url.absoluteString)
            
            isLoading = true
            
            do {
                let res = try await networkManager.getDataWithAsync(url: url, type: WeatherForecastResponse.self)
                self.weatherList = res.list
                self.city = res.city
                self.fiveDayForecast = res.getDailyForecast()
                self.isLoading = false
            } catch {
                self.isLoading = false
                await handleGetWeatherForecasetError(error: error)
            }
        }
    }
    
    private func handleGetWeatherForecasetError(error: Error) async {
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
    
    func addCity(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
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
    private func getWeatherForecastAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = ApiKeys.weatherApiKey) -> String {
        guard let currentLocation else { return "" }
        return "\(urlString)forecast?lat=\(currentLocation.coordinate.latitude)&lon=\(currentLocation.coordinate.longitude)&appid=\(apiKey)"
    }
    
    /**
        Get url by using City data.
     */
    private func getWeatherForecaseAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = ApiKeys.weatherApiKey, city: City) -> String {
        return "\(urlString)forecast?lat=\(city.coordinate.lat)&lon=\(city.coordinate.lon)&appid=\(apiKey)"
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
