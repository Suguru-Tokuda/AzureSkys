//
//  GooglePlaceDetailsResponse.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/28/23.
//

import Foundation

struct GooglePlaceDetailsResponse: Decodable {
    let result: GooglePlaceDetails
}

struct GooglePlaceDetails: Decodable {
    let id: String
    let formattedAddress: String
    let geometry: GooglePlaceGeometry
    let name: String
    let addressComponents: [GooglePlaceAddressComponent]
    
    enum CodingKeys: String, CodingKey {
        case id = "place_id"
        case formattedAddress = "formatted_address"
        case geometry
        case name
        case addressComponents = "address_components"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.formattedAddress = try container.decode(String.self, forKey: .formattedAddress)
        self.geometry = try container.decode(GooglePlaceGeometry.self, forKey: .geometry)
        self.name = try container.decode(String.self, forKey: .name)
        self.addressComponents = try container.decode([GooglePlaceAddressComponent].self, forKey: .addressComponents)
    }
    
    init(id: String, formattedAddress: String, geometry: GooglePlaceGeometry, name: String, addressComponents: [GooglePlaceAddressComponent]) {
        self.id = id
        self.formattedAddress = formattedAddress
        self.geometry = geometry
        self.name = name
        self.addressComponents = addressComponents
    }
}

struct GooglePlaceAddressComponent: Decodable {
    let longName, shortName: String
    let types: [String]
    
    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
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
