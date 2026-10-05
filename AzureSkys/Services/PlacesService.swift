//
//  PlacesService.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/1/26.
//

import Foundation

protocol PlacesServicing {
    func getPredictions(query: String) async throws -> [Prediction]
    func getPlaceDetails(placeID: String) async throws -> SavedPlace
}

final class PlacesService: PlacesServicing {
    private let networkManager: Networking
    private let apiKeyManager: ApiKeyActions
    private let baseURL: String

    init(networkManager: Networking, apiKeyManager: ApiKeyActions,
         baseURL: String = Constants.googleApiBaseURL) {
        self.networkManager = networkManager
        self.apiKeyManager = apiKeyManager
        self.baseURL = baseURL
    }

    func getPredictions(query: String) async throws -> [Prediction] {
        try Task.checkCancellation()
        let url = try placesURL(endpoint: Strings.autocompleteJson.rawValue, queryItems: [
            URLQueryItem(name: Strings.input.rawValue, value: query),
            URLQueryItem(name: Strings.types.rawValue, value: Strings.citiesFilter.rawValue),
            URLQueryItem(name: Strings.fields.rawValue, value: Strings.autocompleteFields.rawValue)
        ])
        let response = try await networkManager.getData(url: url, type: GoogleAutoCompleteModel.self)
        try Task.checkCancellation()
        return response.predictions ?? []
    }

    func getPlaceDetails(placeID: String) async throws -> SavedPlace {
        try Task.checkCancellation()
        let url = try placesURL(endpoint: Strings.detailsJson.rawValue, queryItems: [
            URLQueryItem(name: Strings.placeid.rawValue, value: placeID),
            URLQueryItem(name: Strings.fields.rawValue, value: Strings.placeDetailFields.rawValue)
        ])
        let response = try await networkManager.getData(url: url, type: GooglePlaceDetailsResponse.self)
        try Task.checkCancellation()
        return SavedPlace(details: response.result)
    }

    private func placesURL(endpoint: String, queryItems: [URLQueryItem]) throws -> URL {
        guard let key = try? apiKeyManager.getGoogleApiKey(),
              var components = URLComponents(string: baseURL + endpoint) else { throw NetworkError.badUrl }
        components.queryItems = queryItems + [URLQueryItem(name: Strings.key.rawValue, value: key)]
        guard let url = components.url else { throw NetworkError.badUrl }
        return url
    }
}

extension SavedPlace {
    init(details: GooglePlaceDetails) {
        self.init(id: details.id, name: details.name,
                  formattedAddress: details.formattedAddress,
                  latitude: details.geometry.location.latitude,
                  longitude: details.geometry.location.longitude,
                  addressComponents: details.addressComponents.map {
                      PlaceAddressComponent(longName: $0.longName, shortName: $0.shortName, types: $0.types)
                  })
    }
}
