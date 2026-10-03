//
//  LocationAuthorizationRequestViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class LocationAuthorizationRequestViewTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(try await renderSnapshot(LocationAuthorizationRequestView(settingsManager: SettingsManager(canOpen: { _ in false }, open: { _ in }))))
    }
}
