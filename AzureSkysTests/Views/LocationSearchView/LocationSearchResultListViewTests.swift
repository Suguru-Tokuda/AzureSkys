//
//  LocationSearchResultListViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class LocationSearchResultListViewTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(
            try await renderSnapshot(
                LocationSearchResultListView(predictions: Array(PreviewManager.predictions.prefix(1)))
            )
        )
    }
}
