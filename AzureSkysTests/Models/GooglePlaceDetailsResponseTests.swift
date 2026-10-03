//
//  GooglePlaceDetailsResponseTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class GooglePlaceDetailsResponseTests: XCTestCase {
    func testProviderGeometryAndAddressMappings() throws {
        let details = GooglePlaceDetails(id: "city", formattedAddress: "City, USA", geometry: .init(location: .init(latitude: 12, longitude: 34)), name: "City", addressComponents: [.init(longName: "City", shortName: "C", types: ["locality"])])
        let saved = SavedPlace(details: details)
        XCTAssertEqual(saved.id, details.id)
        XCTAssertEqual(saved.name, details.name)
        XCTAssertEqual(saved.latitude, 12)
        XCTAssertEqual(saved.longitude, 34)
        XCTAssertEqual(saved.addressComponents.first?.types, ["locality"])
    }

    func testInvalidResponseIsRejected() {
        XCTAssertThrowsError(try JSONDecoder().decode(GooglePlaceDetailsResponse.self, from: Data(#"{"result":{}}"#.utf8)))
    }
}
