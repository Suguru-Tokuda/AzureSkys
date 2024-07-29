//
//  WeatherGeocodeResponse.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/12/23.
//

import Foundation

struct WeatherGeocode: Decodable {
    let name: String
    let latitude, longitude: Double
    let country: String
    let state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case latitude = "lat", longitude = "lon", country, state
    }
}
