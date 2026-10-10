//
//  WeatherDailyForecastListViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class WeatherDailyForecastListViewTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(
            try await renderSnapshot(
                WeatherDailyForecastListView(
                    list: PreviewManager.oneCallResponse.daily,
                    timezoneOffset: 0,
                    showAnimation: false
                )
            )
        )
    }
}
