//
//  GoogleAutoCompleteModelTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class GoogleAutoCompleteModelTests: XCTestCase {
    func testOptionalFieldsAndProviderMappings() throws {
        let data = Data(
            #"{"status":"OK","predictions":[{"place_id":"city","description":"City","structured_formatting":{"main_text":"City","secondary_text":"USA"}}]}"#
                .utf8
        )

        let response = try JSONDecoder().decode(GoogleAutoCompleteModel.self, from: data)

        XCTAssertEqual(response.status, "OK")

        let prediction = try XCTUnwrap(response.predictions?.first)

        XCTAssertEqual(prediction.placeId, "city")
        XCTAssertEqual(prediction.structuredFormatting?.mainText, "City")
        XCTAssertEqual(prediction.structuredFormatting?.secondaryText, "USA")

        let empty = try JSONDecoder().decode(GoogleAutoCompleteModel.self, from: Data("{}".utf8))

        XCTAssertNil(empty.predictions)

        let minimal = try JSONDecoder().decode(Prediction.self, from: Data(#"{"place_id":"minimal"}"#.utf8))

        XCTAssertNil(minimal.description)
        XCTAssertNil(minimal.structuredFormatting)
    }

    func testConstructedPredictionsKeepIdentity() {
        let id = UUID()
        let prediction = Prediction(id: id, description: "City", placeId: "city", structuredFormatting: nil, types: [])

        XCTAssertEqual(prediction.id, id)
        XCTAssertEqual(prediction.description, "City")
    }
}
