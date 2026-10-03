//
//  TempScaleTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class TempScaleTests: XCTestCase {
    func testDisplayNamesPreserveLegacyPreferenceValues() {
        XCTAssertEqual(TempScale.fahrenheit.rawValue, "Fahrenheight")
        XCTAssertEqual(TempScale.fahrenheit.displayName, "Fahrenheit")
        XCTAssertEqual(TempScale.celsius.displayName, "Celsius")
        XCTAssertEqual(Set(TempScale.allCases.map(\.id)).count, 2)
    }
}
