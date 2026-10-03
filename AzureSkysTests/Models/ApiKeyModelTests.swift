//
//  ApiKeyModelTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class ApiKeyModelTests: XCTestCase {
    func testDecodingUsesProviderKeysAndRejectsMissingKeys() throws {
        let data = Data(#"{"GOOGLE_API_KEY":"fake-google","OPEN_WEATHER_API_KEY":"fake-weather"}"#.utf8)
        let model = try JSONDecoder().decode(ApiKeyModel.self, from: data)
        XCTAssertEqual(model.googleApiKey, "fake-google")
        XCTAssertEqual(model.openWeatherApiKey, "fake-weather")
        XCTAssertThrowsError(try JSONDecoder().decode(ApiKeyModel.self, from: Data("{}".utf8)))
    }
}
