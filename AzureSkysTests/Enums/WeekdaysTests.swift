//
//  WeekdaysTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class WeekdaysTests: XCTestCase {
    func testAllCalendarValuesAndInvalidFallback() {
        let expected: [Weekdays] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]

        for (index, value) in expected.enumerated() {
            XCTAssertEqual(Weekdays.getWeekday(day: index + 1), value)
        }

        XCTAssertEqual(Weekdays.getWeekday(day: 0), .sunday)
        XCTAssertEqual(Weekdays.getWeekday(day: 8), .sunday)
    }
}
