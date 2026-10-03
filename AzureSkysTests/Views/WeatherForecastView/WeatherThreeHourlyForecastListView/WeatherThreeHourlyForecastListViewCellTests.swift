//
//  WeatherThreeHourlyForecastListViewCellTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class WeatherThreeHourlyForecastListViewCellTests: XCTestCase {
    func testDisplayedStateChangesRenderedContent() async throws {
        try await assertDifferent(WeatherThreeHourlyForecastListViewCell(forecast: PreviewManager.oneCallResponse.current, timezoneOffset: 0, isFirst: true), WeatherThreeHourlyForecastListViewCell(forecast: PreviewManager.oneCallResponse.current, timezoneOffset: 0, isFirst: false))
    }
}
