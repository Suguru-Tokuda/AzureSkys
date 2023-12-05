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
    var apiCancellables = Set<AnyCancellable>()
    
    var networkManager: Networking
    var locationManager: LocationManager?
    
    init(networkManager: Networking = NetworkManager()) {
        self.networkManager = networkManager
    }
        
    deinit {
        self.cancellables.removeAll()
        self.apiCancellables.removeAll()
    }
    
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
    
    func getWeatherForecasetData(urlString: String = Constants.weatherApiEndpoint) async {
        if !isLoading && currentLocation != nil {
            apiCancellables.removeAll()
            
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
                self.fiveDayForecast.forEach { forecast in
                    print(forecast)
                }
                self.isLoading = false
            } catch {
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
    
    func setLocationManager(locationManager: LocationManager) {
        self.locationManager = locationManager
        self.cancellables.removeAll()
        self.addLocationSubscriptions()
    }
    
    private func getWeatherForecaseAPIString(urlString: String = Constants.weatherApiEndpoint, apiKey: String = Constants.googleApiKey) -> String {
        guard let currentLocation else { return "" }
        return "\(urlString)?lat=\(currentLocation.coordinate.latitude)&lon=\(currentLocation.coordinate.longitude)&appid=\(apiKey)"
    }
}
