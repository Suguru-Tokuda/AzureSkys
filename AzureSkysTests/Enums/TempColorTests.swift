//
//  TempColorTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

final class TempColorTests: XCTestCase {
    func testClassificationBoundaries() {
        let cases: [(Double, TempColor)] = [(-20, .freezing), (4.9, .freezing), (5, .cold), (9.9, .cold), (10, .cool), (14.9, .cool), (15, .warm), (37.8, .warm), (37.9, .hot)]
        for (celsius, expected) in cases { XCTAssertEqual(TempColor.getTempColor(tempInKelvin: celsius + 273.15), expected) }
    }

    func testTemperatureCategoriesUseExpectedColors() {
        XCTAssertEqual(TempColor.freezing.getColor(), .cold)
        XCTAssertEqual(TempColor.cold.getColor(), .cold)
        XCTAssertEqual(TempColor.cool.getColor(), .cool)
        XCTAssertEqual(TempColor.warm.getColor(), .warm)
        XCTAssertEqual(TempColor.hot.getColor(), .hot)
    }
}
