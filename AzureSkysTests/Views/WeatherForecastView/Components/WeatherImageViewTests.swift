import XCTest
import SwiftUI
import UIKit
@testable import AzureSkys

@MainActor
final class WeatherImageViewTests: XCTestCase {
    func testEveryConditionHasBundledDayAndNightArtwork() {
        for condition in WeatherCondition.allCases {
            for partOfDay in [PartOfDay.day, .night] {
                let name = condition.iconAssetName(partOfDay: partOfDay)
                XCTAssertNotNil(UIImage(named: name), "Missing asset: \(name)")
            }
        }
    }

    func testEveryConditionRendersDifferentDayAndNightArtwork() async throws {
        for condition in WeatherCondition.allCases {
            let day = try await renderSnapshot(WeatherImageView(condition: condition, width: 40))
            let night = try await renderSnapshot(WeatherImageView(condition: condition, partOfDay: .night, width: 40))
            assertVisibleContent(day)
            assertVisibleContent(night)
            XCTAssertNotEqual(day.pngData(), night.pngData(), "Expected distinct artwork for \(condition)")
        }
    }
}
