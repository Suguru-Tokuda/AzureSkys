//
//  ConstantsTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class ConstantsTests: XCTestCase {
    func testAPIAndIconURLsUseHTTPS() {
        for value in [
            Constants.weatherApiEndpoint, Constants.googleApiBaseURL,
            Constants.weatherIconURL.replacingOccurrences(of: "ICON_CODE", with: "01d")
        ] {
            XCTAssertEqual(URL(string: value)?.scheme, "https")
            XCTAssertNotNil(URL(string: value)?.host)
        }

        XCTAssertEqual(Constants.dateFormat, "yyyy-MM-dd HH:mm:ss")
    }
}
