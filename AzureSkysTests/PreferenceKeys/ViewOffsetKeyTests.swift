//
//  ViewOffsetKeyTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

final class ViewOffsetKeyTests: XCTestCase {
    func testOffsetsAccumulateFromZero() {
        var value = ViewOffsetKey.defaultValue
        ViewOffsetKey.reduce(value: &value) { 12 }
        ViewOffsetKey.reduce(value: &value) { -5 }
        XCTAssertEqual(value, 7)
    }
}
