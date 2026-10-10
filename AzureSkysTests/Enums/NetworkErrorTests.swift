//
//  NetworkErrorTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class NetworkErrorTests: XCTestCase {
    func testEveryErrorHasDistinctUserFacingDescription() {
        let errors: [NetworkError] = [.badUrl, .dataParsingError, .serverError, .noData, .networkUnavailable, .unknown]
        let descriptions = errors.map { $0.localizedDescription }

        XCTAssertTrue(descriptions.allSatisfy { !$0.isEmpty })
        XCTAssertEqual(Set(descriptions).count, errors.count)
    }

    func testURLAndUnknownErrorMapping() {
        XCTAssertEqual(NetworkError(URLError(.badURL)), .badUrl)
        XCTAssertEqual(NetworkError(URLError(.unsupportedURL)), .badUrl)
        XCTAssertEqual(NetworkError(URLError(.timedOut)), .unknown)
        XCTAssertEqual(NetworkError(NSError(domain: "Test", code: 1)), .unknown)

        for code in [URLError.Code.cannotFindHost, .cannotConnectToHost, .dnsLookupFailed] {
            XCTAssertEqual(NetworkError(URLError(code)), .networkUnavailable)
        }
    }
}
