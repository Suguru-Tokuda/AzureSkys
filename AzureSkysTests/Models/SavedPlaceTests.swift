//
//  SavedPlaceTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class SavedPlaceTests: XCTestCase {
    func testDomainEqualityAndAddressStorageFormat() throws {
        XCTAssertEqual(testPlace, testPlace)
        let data = try JSONEncoder().encode(testPlace.addressComponents)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        XCTAssertEqual(json.first?["short_name"] as? String, "TC")
        XCTAssertEqual(try JSONDecoder().decode([PlaceAddressComponent].self, from: data), testPlace.addressComponents)
    }
}
