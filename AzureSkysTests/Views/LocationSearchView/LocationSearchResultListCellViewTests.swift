//
//  LocationSearchResultListCellViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class LocationSearchResultListCellViewTests: XCTestCase {
    func testDisplayedStateChangesRenderedContent() async throws {
        try await assertDifferent(
            LocationSearchResultListCellView(
                prediction: Prediction(id: UUID(), description: "Chicago", placeId: "city")
            ),
            LocationSearchResultListCellView(
                prediction: Prediction(id: UUID(), description: "Atlanta", placeId: "city")
            )
        )
    }
}
