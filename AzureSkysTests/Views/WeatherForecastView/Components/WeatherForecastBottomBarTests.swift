//
//  WeatherForecastBottomBarTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class WeatherForecastBottomBarTests: XCTestCase {
    func testLocationsControlRendersOverWeatherBackground() async throws {
        assertVisibleContent(try await renderSnapshot(WeatherForecastBottomBar()))
    }
}
