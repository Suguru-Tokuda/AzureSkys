//
//  StringTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class StringTests: XCTestCase {
    func testDegreeSuffixAndDateReformatting() {
        XCTAssertEqual("-5".appendDegree(), "-5°")
        XCTAssertEqual("2023-12-25".getDateStrinng(dateFormat: "yyyy-MM-dd", newDateFormat: "yyyy"), "2023")
        XCTAssertEqual(Calendar.current.component(.day, from: "2023-12-25".getDate(dateFormat: "yyyy-MM-dd")), 25)
    }

    func testInvalidDateFallsBackToCurrentTime() {
        let before = Date()
        let date = "invalid".getDate(dateFormat: "yyyy-MM-dd")

        XCTAssertGreaterThanOrEqual(date, before)
        XCTAssertLessThanOrEqual(date, Date())
    }
}
