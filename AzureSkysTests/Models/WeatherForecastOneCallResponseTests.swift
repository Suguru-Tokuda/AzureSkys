//
//  WeatherForecastOneCallResponseTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class WeatherForecastOneCallResponseTests: XCTestCase {
    func testHourlyAndDailyFieldsDecode() throws {
        let value = try TestFixtures.oneCall()
        XCTAssertEqual(value.latitude, 12.5)
        XCTAssertEqual(value.timezoneOffset, 0)
        XCTAssertEqual(value.current.feelsLike, 279)
        XCTAssertEqual(value.hourly.first?.probabilityOfPrecipitation, 0.2)
        XCTAssertEqual(value.daily.first?.temp.max, 282)
        XCTAssertEqual(value.daily.first?.moonPhase, 0.5)
        let daily = try XCTUnwrap(value.daily.first)
        XCTAssertEqual(try JSONDecoder().decode(Temp.self, from: JSONEncoder().encode(daily.temp)).min, 278)
        XCTAssertEqual(try JSONDecoder().decode(FeelsLike.self, from: JSONEncoder().encode(daily.feelsLike)).night, 278)
    }

    func testOptionalForecastFieldsAndRequiredFields() throws {
        var object = try TestFixtures.object(TestFixtures.oneCallData)
        var current = object["current"] as! [String: Any]
        for key in ["sunrise", "sunset", "pressure", "humidity", "dew_point", "uvi", "clouds", "visibility", "wind_deg", "wind_gust", "pop"] { current.removeValue(forKey: key) }
        object["current"] = current
        let value = try JSONDecoder().decode(WeatherForecastOneCallResponse.self, from: TestFixtures.data(object))
        XCTAssertNil(value.current.uvi)
        XCTAssertNil(value.current.windGust)
        object.removeValue(forKey: "daily")
        XCTAssertThrowsError(try JSONDecoder().decode(WeatherForecastOneCallResponse.self, from: TestFixtures.data(object)))
    }
}
