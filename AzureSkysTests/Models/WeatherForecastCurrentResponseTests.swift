//
//  WeatherForecastCurrentResponseTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class WeatherForecastCurrentResponseTests: XCTestCase {
    func testCurrentForecastMapsProviderFields() throws {
        let value = try TestFixtures.current()
        XCTAssertEqual(value.dateTime, 1700000000)
        XCTAssertEqual(value.coordinate.latitude, 12.5)
        XCTAssertEqual(value.coordinate.longitude, -34.5)
        XCTAssertEqual(value.main.feelsLike, 279)
        XCTAssertEqual(value.system.country, "US")
        XCTAssertEqual(value.name, "Test City")
        XCTAssertEqual(value.clouds.all, 20)
        XCTAssertEqual(value.weather.first?.partOfDay, .day)
    }
}
