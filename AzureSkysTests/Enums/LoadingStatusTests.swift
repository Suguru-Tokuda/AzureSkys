//
//  LoadingStatusTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class LoadingStatusTests: XCTestCase {
    func testDistinctLifecycleStates() {
        XCTAssertNotEqual(LoadingStatus.inactive, .loading)
        XCTAssertNotEqual(LoadingStatus.loading, .loaded)
        XCTAssertNotEqual(LoadingStatus.loaded, .inactive)
    }
}
