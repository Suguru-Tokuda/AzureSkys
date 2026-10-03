//
//  StatusGridViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class StatusGridViewTests: XCTestCase {
    func testOptionalWeatherMetricsChangeRenderedGrid() async throws {
        let full = try TestFixtures.oneCall().current
        var object = try TestFixtures.object(TestFixtures.oneCallData)
        var current = object["current"] as! [String: Any]
        for key in ["visibility", "humidity", "pressure", "clouds", "uvi", "dew_point", "wind_gust"] { current.removeValue(forKey: key) }
        object["current"] = current
        let minimal = try JSONDecoder().decode(WeatherForecastOneCallResponse.self, from: TestFixtures.data(object)).current
        try await assertDifferent(StatusGridView(forecast: full, background: Color.skyBlue100, parentViewWidth: 390), StatusGridView(forecast: minimal, background: Color.skyBlue100, parentViewWidth: 390))
    }
}
