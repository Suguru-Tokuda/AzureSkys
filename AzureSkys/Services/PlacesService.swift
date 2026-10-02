//
//  PlacesService.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/1/26.
//

import Foundation

protocol PlacesServicing {
    func getPredictions(query: String) async throws -> [Prediction]
    func getPlaceDetails(placeID: String) async throws -> GooglePlaceDetails
}

final class PlacesService: PlacesServicing {
    private let networkManager: Networking
    private let apiKeyManager: ApiKeyActions
    private let baseURL: String

    init(networkManager: Networking = NetworkManager(), apiKeyManager: ApiKeyActions = ApiKeyManager(),
         baseURL: String = Constants.googleApiBaseURL) {
        self.networkManager = networkManager
        self.apiKeyManager = apiKeyManager
        self.baseURL = baseURL
    }

    func getPredictions(query: String) async throws -> [Prediction] {
        try Task.checkCancellation()
        let url = try placesURL(endpoint: "autocomplete/json", queryItems: [
            URLQueryItem(name: "input", value: query),
            URLQueryItem(name: "types", value: "(cities)"),
            URLQueryItem(name: "fields", value: "place_id,description")
        ])
        let response = try await networkManager.getData(url: url, type: GoogleAutoCompleteModel.self)
        try Task.checkCancellation()
        return response.predictions ?? []
    }

    func getPlaceDetails(placeID: String) async throws -> GooglePlaceDetails {
        try Task.checkCancellation()
        let url = try placesURL(endpoint: "details/json", queryItems: [
            URLQueryItem(name: "placeid", value: placeID),
            URLQueryItem(name: "fields", value: "geometry,formatted_address,name,place_id,address_components")
        ])
        let response = try await networkManager.getData(url: url, type: GooglePlaceDetailsResponse.self)
        try Task.checkCancellation()
        return response.result
    }

    private func placesURL(endpoint: String, queryItems: [URLQueryItem]) throws -> URL {
        guard let key = try? apiKeyManager.getGoogleApiKey(),
              var components = URLComponents(string: baseURL + endpoint) else { throw NetworkError.badUrl }
        components.queryItems = queryItems + [URLQueryItem(name: "key", value: key)]
        guard let url = components.url else { throw NetworkError.badUrl }
        return url
    }
}
