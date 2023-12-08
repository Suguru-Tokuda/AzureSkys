//
//  CurrentWeatherForecastViewModel.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/7/23.
//

import Combine
import MapKit

@MainActor
class CurrentWeatherForecastViewModel: ObservableObject {
    @Published var currentForecast: WeatherForecastCurrentResponse?
    @Published var isLoading = false
    @Published var isErrorOccured = false
    @Published var customError: NetworkError?
    @Published var locationAuthorized: Bool = false
    var city: City?
    
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
    
    func setCity(city: City) {
        self.city = city
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
                self.isLoading = false
            } catch {
                self.isLoading = false
                await handleGetWeatherForecasetError(error: error)
            }
        }
    }
    
    func getCurrentWeatherDataWithCityData(urlString: String = Constants.weatherApiEndpoint) async {
        if let city,
           !isLoading {
            guard let url = URL(string: getCurrentWeatherForecastAPIString(coordinate: CLLocationCoordinate2D(latitude: city.coordinate.lat, longitude: city.coordinate.lon))) else {
                isErrorOccured = true
                customError = NetworkError.badUrl
                return
            }
            
            isLoading = true
            
            do {
                self.currentForecast = try await networkManager.getDataWithAsync(url: url, type: WeatherForecastCurrentResponse.self)
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
        Get url for current by coordinate
     */
    private func getCurrentWeatherForecastAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = ApiKeys.weatherApiKey, coordinate: CLLocationCoordinate2D) -> String {
        return "\(urlString)weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)"
    }
}
