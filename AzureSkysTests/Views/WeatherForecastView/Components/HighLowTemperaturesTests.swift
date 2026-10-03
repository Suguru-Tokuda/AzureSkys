//
//  HighLowTemperaturesTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class HighLowTemperaturesTests: XCTestCase {
    func testDisplayedStateChangesRenderedContent() async throws {
        try await assertDifferent(HighLowTemperatures(maxTemp: 300, minTemp: 280), HighLowTemperatures(maxTemp: 270, minTemp: 250))
    }
}
