//
//  WindStatusGridViewCellTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class WindStatusGridViewCellTests: XCTestCase {
    func testDisplayedStateChangesRenderedContent() async throws {
        try await assertDifferent(WindStatusGridViewCell(width: 150, background: Color.skyBlue100, wind: Wind(speed: 5, gust: 10, deg: 0)), WindStatusGridViewCell(width: 150, background: Color.skyBlue100, wind: Wind(speed: 5, gust: nil, deg: nil)))
    }
}
