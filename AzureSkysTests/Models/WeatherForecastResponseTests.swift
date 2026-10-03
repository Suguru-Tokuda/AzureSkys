//
//  WeatherForecastResponseTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class WeatherForecastResponseTests: XCTestCase {
    func testLegacyFieldsPrecipitationAndDayNightMapping() throws {
        let value = try JSONDecoder().decode(WeatherForecastResponse.self, from: TestFixtures.legacyData)
        XCTAssertEqual(value.statusCode, 200)
        XCTAssertEqual(value.list.first?.rain?.rainVolumeForNext3HoursInMM, 1.5)
        XCTAssertEqual(value.list.first?.snow?.snowVolumeForNext3HoursInMM, 0.5)
        XCTAssertEqual(value.list.first?.partOfDay, .day)
        XCTAssertEqual(value.city.coordinate.lat, 12.5)
        var object = try TestFixtures.object(TestFixtures.legacyData)
        var row = (object["list"] as! [[String: Any]])[0]
        row["sys"] = ["pod": "n"]
        row.removeValue(forKey: "rain"); row.removeValue(forKey: "snow")
        object["list"] = [row]; object["cod"] = "invalid"
        let night = try JSONDecoder().decode(WeatherForecastResponse.self, from: TestFixtures.data(object))
        XCTAssertEqual(night.statusCode, 0)
        XCTAssertEqual(night.list.first?.partOfDay, .night)
        XCTAssertNil(night.list.first?.rain)
        XCTAssertNil(night.list.first?.snow)
    }

    func testDailySamplingAcrossPartialDayAndEmptyList() throws {
        let fixture = try JSONDecoder().decode(WeatherForecastResponse.self, from: TestFixtures.legacyData)
        let rows = Array(repeating: fixture.list[0], count: 18)
        let value = WeatherForecastResponse(statusCode: 200, message: 0, count: 18, list: rows, city: fixture.city)
        XCTAssertEqual(value.getDailyForecast().count, 3)
        let empty = WeatherForecastResponse(statusCode: 200, message: 0, count: 0, list: [], city: fixture.city)
        XCTAssertTrue(empty.getDailyForecast().isEmpty)
    }

    func testWeatherIconsAndUnknownConditions() throws {
        for (icon, expected) in [("01d", PartOfDay.day), ("01n", .night)] {
            let data = try TestFixtures.data(["id": 1, "main": "unrecognized", "description": "unknown", "icon": icon])
            let weather = try JSONDecoder().decode(Weather.self, from: data)
            XCTAssertEqual(weather.partOfDay, expected)
            XCTAssertEqual(weather.weatherCondition, .clear)
        }
    }
}
