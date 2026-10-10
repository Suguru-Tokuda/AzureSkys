//
//  WeatherForecastMainViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class WeatherForecastMainViewTests: XCTestCase {
    func testRendersWithInjectedDependencies() async throws {
        let dependencies = AppDependencies.preview()

        assertVisibleContent(
            try await renderSnapshot(WeatherForecastMainView(dependencies: dependencies), dependencies: dependencies)
        )
    }
}
