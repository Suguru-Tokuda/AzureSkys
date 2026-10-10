//
//  WeatherGeocodeTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class WeatherGeocodeTests: XCTestCase {
    func testOptionalStateAndCoordinatesDecode() throws {
        let value = try JSONDecoder().decode(
            WeatherGeocode.self,
            from: Data(#"{"name":"City","lat":12,"lon":34,"country":"US"}"#.utf8)
        )
        XCTAssertEqual(value.latitude, 12)
        XCTAssertEqual(value.longitude, 34)
        XCTAssertEqual(value.country, "US")
        XCTAssertNil(value.state)

        let withState = try JSONDecoder().decode(
            WeatherGeocode.self,
            from: Data(#"{"name":"City","lat":12,"lon":34,"country":"US","state":"IL"}"#.utf8)
        )
        XCTAssertEqual(withState.state, "IL")
    }
}
