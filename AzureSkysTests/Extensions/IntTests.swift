//
//  IntTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class IntTests: XCTestCase {
    func testDistanceConversionTruncatesToWholeMiles() {
        XCTAssertEqual(0.toMiles(), 0)
        XCTAssertEqual(1609.toMiles(), 0)
        XCTAssertEqual(1610.toMiles(), 1)
        XCTAssertEqual(10000.toMiles(), 6)
    }

    func testRelativeTimeFormatsToday() {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        XCTAssertEqual(0.getTimeStr(dateFormat: "yyyy-MM-dd"), formatter.string(from: Date()))
    }

    func testUnixFormattingUsesRequestedOffset() {
        // Characterize the current five-hour adjustment until its legacy callers are migrated.
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd HH:mm"
        XCTAssertEqual(0.unixTimeToDateStr(dateFormat: formatter.dateFormat, timezoneOffset: 3600), formatter.string(from: Date(timeIntervalSince1970: 21600)))
    }
}
