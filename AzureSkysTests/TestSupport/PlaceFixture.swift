//
//  PlaceFixture.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import Foundation
@testable import AzureSkys

var testPlace: SavedPlace {
    SavedPlace(id: "test-city", name: "Test City", formattedAddress: "Test City, USA",
               latitude: 12.5, longitude: -34.5,
               addressComponents: [.init(longName: "Test City", shortName: "TC", types: ["locality"])])
}
