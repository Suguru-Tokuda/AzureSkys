//
//  CurrentWeatherForecastViewModel.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/7/23.
//

import Combine
import MapKit
import SwiftUI

@MainActor
class CurrentWeatherForecastViewModel: ObservableObject {
    @Published var currentForecast: WeatherForecastCurrentResponse?
    @Published var isLoading = false
    @Published var isErrorOccured = false
    @Published var customError: NetworkError?
    @Published var locationAuthorized: Bool = false
    @Published var listRowBackground: LinearGradient = .init(gradient: Gradient(colors: [Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
    var place: GooglePlaceDetails?
    
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
                .sink { receiveVal in
                    self.locationAuthorized = receiveVal.0
                    self.currentLocation = receiveVal.1
                    
                    if self.currentForecast == nil {
                        Task {
                            await self.getCurrentWeatherDataWithCurrentLocation()
                        }
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func getCurrentWeatherDataWithCurrentLocation(urlString: String = Constants.weatherApiEndpoint) async {
        if let currentLocation,
           !isLoading {
            guard let url = URL(string: getCurrentWeatherForecastAPIString(urlString: urlString, coordinate: currentLocation.coordinate)) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
            isLoading = true
            
            do {
                self.currentForecast = try await networkManager.getDataWithAsync(url: url, type: WeatherForecastCurrentResponse.self)
                if let currentForecast = self.currentForecast,
                   let weather = currentForecast.weather.first {
                    self.setRowBackgroundColor(weather: weather)
                }
                
                self.isLoading = false
            } catch {
                self.isLoading = false
                await handleGetWeatherForecastError(error: error)
            }
        }
    }
    
    func getCurrentWeatherDataWithCityData(urlString: String = Constants.weatherApiEndpoint) async {
        if let place,
           !isLoading {
            guard let url = URL(string: getCurrentWeatherForecastAPIString(coordinate: CLLocationCoordinate2D(latitude: place.geometry.location.latitude, longitude: place.geometry.location.longitude))) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
            isLoading = true
            
            do {
                self.currentForecast = try await networkManager.getDataWithAsync(url: url, type: WeatherForecastCurrentResponse.self)
                if let currentForecast = self.currentForecast,
                   let weather = currentForecast.weather.first {
                    self.setRowBackgroundColor(weather: weather)
                }
                self.isLoading = false
            } catch {
                self.isLoading = false
                await handleGetWeatherForecastError(error: error)
            }
        }
    }
    
    private func setRowBackgroundColor(weather: Weather) {
        self.listRowBackground = weather.weatherCondition.getBackGroundColor(partOfDay: weather.partOfDay)
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
    private func getCurrentWeatherForecastAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = ApiKeys.weatherApiKey, coordinate: CLLocationCoordinate2D) -> String {
        return "\(urlString)/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)"
    }
}
