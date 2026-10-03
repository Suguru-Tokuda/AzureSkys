//
//  ViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class ViewTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(try await renderSnapshot(Text("Forecast").backgroundBlur(radius: 4, opaque: true)))
    }
}
