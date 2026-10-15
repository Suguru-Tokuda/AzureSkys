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
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy-MM-dd"
        XCTAssertEqual(0.getTimeStr(dateFormat: "yyyy-MM-dd"), formatter.string(from: Date()))
    }

    func testUnixFormattingUsesDeviceTimeZoneWithoutShiftingTimestamp() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        // Include the epoch and winter/summer dates to cover historical and DST offsets.
        for timestamp in [0, 1736949600, 1752588000, 1792103176] {
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let expected = String(
                format: "%04d-%02d-%02d %02d:%02d",
                components.year!, components.month!, components.day!, components.hour!, components.minute!
            )

            XCTAssertEqual(
                timestamp.unixTimeToDateStr(dateFormat: "yyyy-MM-dd HH:mm"),
                expected,
                "Timestamp: \(timestamp), time zone: \(calendar.timeZone.identifier)"
            )
        }
    }
}
