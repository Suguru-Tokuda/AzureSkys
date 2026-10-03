//
//  StatusGridCellTitleViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class StatusGridCellTitleViewTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(try await renderSnapshot(StatusGridCellTitleView(icon: "wind", title: "Wind")))
    }
}
