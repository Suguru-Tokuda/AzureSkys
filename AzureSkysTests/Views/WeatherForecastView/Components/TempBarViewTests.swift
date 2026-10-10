//
//  TempBarViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class TempBarViewTests: XCTestCase {
    func testDisplayedStateChangesRenderedContent() async throws {
        try await assertDifferent(
            TempBarView(minTemp: 270, maxTemp: 275, showAnimation: false).frame(height: 30),
            TempBarView(minTemp: 300, maxTemp: 320, showAnimation: false).frame(height: 30)
        )
    }
}
