//
//  StatusGridCellViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class StatusGridCellViewTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(try await renderSnapshot(StatusGridCellView(width: 150, background: Color.skyBlue100, icon: "eye", title: "Visibility", value: "6 mi")))
    }
}
