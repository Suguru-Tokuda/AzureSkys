//
//  WeatherForecastScrollViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class WeatherForecastScrollViewTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(try await renderSnapshot(WeatherForecastScrollView(forecast: PreviewManager.oneCallResponse, geocode: PreviewManager.geocode, showAnimation: false)))
    }
}
