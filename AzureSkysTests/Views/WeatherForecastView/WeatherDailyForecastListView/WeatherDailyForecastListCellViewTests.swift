//
//  WeatherDailyForecastListCellViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class WeatherDailyForecastListCellViewTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(
            try await renderSnapshot(
                WeatherDailyForecastListCellView(
                    forecast: PreviewManager.oneCallResponse.daily[0],
                    timezoneOffset: 0,
                    showTempBarAnimation: false
                )
            )
        )
    }
}
