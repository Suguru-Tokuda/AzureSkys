//
//  GooglePlaceDetailsResponse.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import Foundation

struct GooglePlaceDetailsResponse: Decodable {
    let result: GooglePlaceDetailsResult
}

struct GooglePlaceDetailsResult: Decodable {
    let formattedAddress: String
    let geometry: GooglePlaceGeometry
    
    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
        case geometry
    }
}

struct GooglePlaceGeometry: Decodable {
    let location: GooglePlaceLocation
}

struct GooglePlaceLocation: Decodable {
    let latitude, longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}
