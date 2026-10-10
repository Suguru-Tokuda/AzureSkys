//
//  DoubleTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class DoubleTests: XCTestCase {
    func testTemperatureConversionsAtFreezingAndBoiling() {
        XCTAssertEqual(273.15.kelvinToCelsius(), 0, accuracy: 0.0001)
        XCTAssertEqual(273.15.kelvinToFahrenheit(), 32, accuracy: 0.0001)
        XCTAssertEqual(373.15.getDegree(tempScale: .fahrenheit), 212, accuracy: 0.0001)
        XCTAssertEqual(373.15.getDegree(tempScale: .celsius), 100, accuracy: 0.0001)
        XCTAssertEqual(233.15.getDegree(tempScale: .fahrenheit), -40, accuracy: 0.0001)
    }

    func testFormattingHonorsFractionLimit() {
        let formatter = NumberFormatter()

        formatter.maximumFractionDigits = 1
        XCTAssertEqual(12.345.formatDouble(maxFractions: 1), formatter.string(from: 12.345))
        XCTAssertEqual(12.0.formatDouble(maxFractions: 0), "12")
    }
}
