//
//  ApiKeyManagerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import Foundation
@testable import AzureSkys

final class ApiKeyManagerTests: XCTestCase {
    private func bundle(contents: Data) throws -> (Bundle, URL) {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".bundle")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try contents.write(to: directory.appendingPathComponent("Keys.plist"))
        return (try XCTUnwrap(Bundle(path: directory.path)), directory)
    }

    func testReadsSyntheticKeysFromInjectedBundle() throws {
        let data = try PropertyListSerialization.data(fromPropertyList: ["GOOGLE_API_KEY": "fake-google", "OPEN_WEATHER_API_KEY": "fake-weather"], format: .xml, options: 0)
        let (bundle, directory) = try bundle(contents: data)
        defer { try? FileManager.default.removeItem(at: directory) }
        let manager = ApiKeyManager(bundle: bundle, resource: "Keys")
        XCTAssertEqual(try manager.getGoogleApiKey(), "fake-google")
        XCTAssertEqual(try manager.getOpenWeatherApiKey(), "fake-weather")
    }

    func testMissingAndMalformedResourcesReportErrors() throws {
        let (bundle, directory) = try bundle(contents: Data("invalid".utf8))
        defer { try? FileManager.default.removeItem(at: directory) }
        let missing = ApiKeyManager(bundle: bundle, resource: "Missing")
        XCTAssertThrowsError(try missing.getGoogleApiKey()) { XCTAssertEqual($0 as? PlistError, .dataNotFound) }
        XCTAssertThrowsError(try missing.getOpenWeatherApiKey()) { XCTAssertEqual($0 as? PlistError, .dataNotFound) }
        let malformed = ApiKeyManager(bundle: bundle, resource: "Keys")
        XCTAssertThrowsError(try malformed.getData(resource: "Keys", type: ApiKeyModel.self)) { XCTAssertEqual($0 as? PlistError, .url) }
        XCTAssertThrowsError(try malformed.getGoogleApiKey())
        XCTAssertThrowsError(try malformed.getOpenWeatherApiKey())
    }
}
