//
//  UserDefaultKeysTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class UserDefaultKeysTests: XCTestCase {
    func testTemperaturePreferenceKeyRemainsCompatible() {
        XCTAssertEqual(UserDefaultKeys.tempScale.rawValue, "tempScale")
    }
}
