//
//  WeatherThreeHourlyForecastListViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class WeatherThreeHourlyForecastListViewTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(
            try await renderSnapshot(WeatherThreeHourlyForecastListView(forecast: PreviewManager.oneCallResponse))
        )
    }
}
