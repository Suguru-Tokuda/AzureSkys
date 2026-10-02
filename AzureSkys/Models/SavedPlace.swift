//
//  SavedPlace.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/1/26.
//

import Foundation

struct SavedPlace: Identifiable, Equatable {
    let id: String
    let name: String
    let formattedAddress: String
    let latitude: Double
    let longitude: Double
    let addressComponents: [PlaceAddressComponent]
}

struct PlaceAddressComponent: Codable, Equatable {
    let longName: String
    let shortName: String
    let types: [String]

    // Preserve the JSON format already stored in Core Data.
    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
}
