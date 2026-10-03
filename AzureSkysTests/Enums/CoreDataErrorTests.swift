//
//  CoreDataErrorTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class CoreDataErrorTests: XCTestCase {
    func testEveryErrorHasDistinctUserFacingDescription() {
        let errors: [CoreDataError] = [.save, .fetch, .delete]
        let descriptions = errors.map { $0.localizedDescription }
        XCTAssertTrue(descriptions.allSatisfy { !$0.isEmpty })
        XCTAssertEqual(Set(descriptions).count, errors.count)
    }
}
