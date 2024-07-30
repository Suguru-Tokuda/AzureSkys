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
    @Published var isLoading: LoadingStatus = .inactive
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
           isLoading == .inactive {
            
            guard let urlStr = getCurrentWeatherForecastAPIString(urlString: urlString, coordinate: currentLocation.coordinate),
                  let url = URL(string: urlStr) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
            isLoading = .loading
            
            do {
                self.currentForecast = try await networkManager.getData(url: url, type: WeatherForecastCurrentResponse.self)
                if let currentForecast = self.currentForecast,
                   let weather = currentForecast.weather.first {
                    self.setRowBackgroundColor(weather: weather, clouds: currentForecast.clouds.all)
                }
                
                self.isLoading = .inactive
            } catch {
                self.isLoading = .inactive
                await handleGetWeatherForecastError(error: error)
            }
        }
    }
    
    func getCurrentWeatherDataWithCityData(urlString: String = Constants.weatherApiEndpoint) async {
        if let place,
           isLoading == .inactive {
            guard let urlStr = getCurrentWeatherForecastAPIString(coordinate: CLLocationCoordinate2D(latitude: place.geometry.location.latitude, longitude: place.geometry.location.longitude)),
                  let url = URL(string: urlStr) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
            isLoading = .loading
            
            do {
                self.currentForecast = try await networkManager.getData(url: url, type: WeatherForecastCurrentResponse.self)
                if let currentForecast = self.currentForecast,
                   let weather = currentForecast.weather.first {
                    self.setRowBackgroundColor(weather: weather, clouds: currentForecast.clouds.all)
                }
                self.isLoading = .inactive
            } catch {
                self.isLoading = .inactive
                await handleGetWeatherForecastError(error: error)
            }
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
    private func getCurrentWeatherForecastAPIString(urlString: String = Constants.weatherApiEndpoint, coordinate: CLLocationCoordinate2D) -> String? {
        do {
            let apiKey = try apiKeyManager.getOpenWeatherApiKey()
            return "\(urlString)/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)"
        } catch {
            return nil
        }
    }
}
