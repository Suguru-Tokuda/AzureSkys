//
//  StatusGridViewValueLabelModifierTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class StatusGridViewValueLabelModifierTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(try await renderSnapshot(Text("42°").withStatusGridViewValueLabelModifier()))
    }
}
