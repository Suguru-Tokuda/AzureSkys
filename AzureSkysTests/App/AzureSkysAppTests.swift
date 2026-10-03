//
//  AzureSkysAppTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class AzureSkysAppTests: XCTestCase {
    func testAppBuildsItsSceneInUnitTestEnvironment() {
        let app = AzureSkysApp()
        // Evaluating the scene verifies dependency assembly without starting live services.
        XCTAssertFalse(String(reflecting: type(of: app.body)).isEmpty)
    }
}
