//
//  WeatherForecastHeaderViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class WeatherForecastHeaderViewTests: XCTestCase {
    func testDisplayedStateChangesRenderedContent() async throws {
        try await assertDifferent(
            WeatherForecastHeaderView(
                geocode: PreviewManager.geocode,
                currentForecast: PreviewManager.oneCallResponse.current,
                dailyForecast: PreviewManager.oneCallResponse.daily[0],
                isMyLocation: true,
                scrollViewOffsetPercentage: 0
            ),
            WeatherForecastHeaderView(
                geocode: PreviewManager.geocode,
                currentForecast: PreviewManager.oneCallResponse.current,
                dailyForecast: PreviewManager.oneCallResponse.daily[0],
                isMyLocation: false,
                scrollViewOffsetPercentage: 0
            )
        )
    }
}
