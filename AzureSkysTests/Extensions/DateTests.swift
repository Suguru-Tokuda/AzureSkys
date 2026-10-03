//
//  DateTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class DateTests: XCTestCase {
    func testTodayAndOtherWeekdays() {
        XCTAssertEqual(Date().getWeekDayStr(), "Today")
        for offset in 1...7 {
            let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
            let expected = Weekdays.getWeekday(day: Calendar.current.component(.weekday, from: date)).rawValue
            XCTAssertEqual(date.getWeekDayStr(), expected)
        }
    }
}
