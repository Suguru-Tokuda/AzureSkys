//
//  StatusGridViewCellContainerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class StatusGridViewCellContainerTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(try await renderSnapshot(StatusGridViewCellContainer(width: 150, background: Color.skyBlue100) { Text("Forecast") }))
    }
}
