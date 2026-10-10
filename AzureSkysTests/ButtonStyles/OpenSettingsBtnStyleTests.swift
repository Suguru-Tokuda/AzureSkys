//
//  OpenSettingsBtnStyleTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class OpenSettingsBtnStyleTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(
            try await renderSnapshot(
                Button("Open Settings") {}.buttonStyle(
                    OpenSettingsBtnStyle(backgroundColor: .blue, foregroundColor: .white)
                )
            )
        )
    }
}
