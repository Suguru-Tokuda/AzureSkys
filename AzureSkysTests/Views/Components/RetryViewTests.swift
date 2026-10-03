//
//  RetryViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class RetryViewTests: XCTestCase {
    func testDisplayedStateChangesRenderedContent() async throws {
        try await assertDifferent(RetryView(errorMessage: "Offline"), RetryView(errorMessage: nil))
    }
}
