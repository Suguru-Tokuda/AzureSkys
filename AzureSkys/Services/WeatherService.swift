//
//  WeatherService.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/1/26.
//

import Foundation
import CoreLocation

struct WeatherForecastData {
    let forecast: WeatherForecastOneCallResponse
    let geocode: WeatherGeocode?
}

protocol WeatherServicing {
    func getForecast(coordinate: CLLocationCoordinate2D) async throws -> WeatherForecastData
    func getCurrentWeather(coordinate: CLLocationCoordinate2D) async throws -> WeatherForecastCurrentResponse
}

final class WeatherService: WeatherServicing {
    private let networkManager: Networking
    private let apiKeyManager: ApiKeyActions
    private let baseURL: String

    init(networkManager: Networking, apiKeyManager: ApiKeyActions,
         baseURL: String = Constants.weatherApiEndpoint) {
        self.networkManager = networkManager
        self.apiKeyManager = apiKeyManager
        self.baseURL = baseURL
    }

    func getForecast(coordinate: CLLocationCoordinate2D) async throws -> WeatherForecastData {
        guard await networkManager.checkNetworkAvailability(queue: DispatchQueue.global(qos: .background)) else {
            throw NetworkError.networkUnavailable
        }
        try Task.checkCancellation()
        let apiKey = try getAPIKey()
        let forecastURL = try weatherURL(path: Strings.oneCallPath.rawValue, coordinate: coordinate,
                                         apiKey: apiKey, excludeMinutely: true)
        let geocodeURL = try weatherURL(path: Strings.reverseGeocodePath.rawValue, coordinate: coordinate, apiKey: apiKey)
        async let forecast = networkManager.getData(url: forecastURL, type: WeatherForecastOneCallResponse.self)
        async let geocodes = networkManager.getData(url: geocodeURL, type: [WeatherGeocode].self)
        let result = try await (forecast, geocodes)
        try Task.checkCancellation()
        return WeatherForecastData(forecast: result.0, geocode: result.1.first)
    }

    func getCurrentWeather(coordinate: CLLocationCoordinate2D) async throws -> WeatherForecastCurrentResponse {
        try Task.checkCancellation()
        let url = try weatherURL(path: Strings.currentWeatherPath.rawValue, coordinate: coordinate, apiKey: getAPIKey())
        let response = try await networkManager.getData(url: url, type: WeatherForecastCurrentResponse.self)
        try Task.checkCancellation()
        return response
    }

    private func getAPIKey() throws -> String {
        guard let key = try? apiKeyManager.getOpenWeatherApiKey() else { throw NetworkError.badUrl }
        return key
    }

    private func weatherURL(path: String, coordinate: CLLocationCoordinate2D,
                            apiKey: String, excludeMinutely: Bool = false) throws -> URL {
        guard var components = URLComponents(string: baseURL) else { throw NetworkError.badUrl }
        components.path = path
        components.queryItems = [
            URLQueryItem(name: Strings.lat.rawValue, value: String(coordinate.latitude)),
            URLQueryItem(name: Strings.lon.rawValue, value: String(coordinate.longitude)),
            URLQueryItem(name: Strings.appid.rawValue, value: apiKey)
        ]
        if excludeMinutely {
            components.queryItems?.append(URLQueryItem(name: Strings.exclude.rawValue, value: Strings.minutely.rawValue))
        }
        guard let url = components.url else { throw NetworkError.badUrl }
        return url
    }
}
