//
//  WeatherConditionTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class WeatherConditionTests: XCTestCase {
    func testAllKnownConditionsAndUnknownFallback() {
        for condition in WeatherCondition.allCases {
            XCTAssertEqual(WeatherCondition.getWeatherCondition(str: condition.rawValue), condition)
        }

        XCTAssertEqual(WeatherCondition.getWeatherCondition(str: "unknown"), .clear)
    }

    func testCloudBucketsAndDayNightProduceVisibleGradients() async throws {
        for part in [PartOfDay.day, .night] {
            for clouds in [-1, 0, 11, 21, 31, 41, 51, 61, 71, 81, 91, 101] {
                let gradient = WeatherCondition.clouds.getBackgroundColor(partOfDay: part, clouds: clouds)

                assertVisibleContent(try await renderSnapshot(gradient.frame(height: 100)))
            }
        }

        try await assertDifferent(
            WeatherCondition.clear.getBackgroundColor(partOfDay: .day),
            WeatherCondition.clear.getBackgroundColor(partOfDay: .night)
        )
    }
}
