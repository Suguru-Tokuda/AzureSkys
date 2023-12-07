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
    @Published var customError: NetworkError?
    @Published var locationAuthorized: Bool = false

    var currentLocation: CLLocation?
    var cancellables = Set<AnyCancellable>()
    
    var networkManager: Networking
    var locationManager: LocationManager?
    
    init(networkManager: Networking = NetworkManager()) {
        self.networkManager = networkManager
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
                .sink { publisher in
                    self.locationAuthorized = publisher.0
                    let callApi: Bool = self.currentLocation == nil
                    self.currentLocation = publisher.1
                    
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
        if !isLoading && currentLocation != nil {
            guard let url = URL(string: getWeatherForecaseAPIString(urlString: urlString)) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
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
    func getWeatherForecasetData(place: GooglePlaceDetailsResult) async {
        if !isLoading {
            guard let url = URL(string: getWeatherForecaseAPIString(place: place)) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
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
    
    /**
        Get url by using the current location
     */
    private func getWeatherForecaseAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = Constants.weatherApiKey) -> String {
        guard let currentLocation else { return "" }
        return "\(urlString)?lat=\(currentLocation.coordinate.latitude)&lon=\(currentLocation.coordinate.longitude)&appid=\(apiKey)"
    }
    
    /**
        Get url by using City data.
     */
    private func getWeatherForecaseAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = Constants.weatherApiKey, place: GooglePlaceDetailsResult) -> String {
        return "\(urlString)?lat=\(place.geometry.location.latitude)&lon=\(place.geometry.location.longitude)&appid=\(apiKey)"
    }
}
