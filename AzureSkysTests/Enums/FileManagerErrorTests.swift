//
//  FileManagerErrorTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class FileManagerErrorTests: XCTestCase {
    func testEveryErrorHasDistinctUserFacingDescription() {
        let errors: [FileManagerError] = [.data, .badPath, .save, .retrieve]
        let descriptions = errors.map { $0.localizedDescription }

        XCTAssertTrue(descriptions.allSatisfy { !$0.isEmpty })
        XCTAssertEqual(Set(descriptions).count, errors.count)
    }
}
