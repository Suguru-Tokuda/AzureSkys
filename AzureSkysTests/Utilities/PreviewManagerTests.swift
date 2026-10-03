//
//  PreviewManagerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class PreviewManagerTests: XCTestCase {
    func testFixturesProvideConsistentRenderableForecasts() {
        let oneCall = PreviewManager.oneCallResponse
        XCTAssertFalse(oneCall.daily.isEmpty)
        XCTAssertFalse(oneCall.hourly.isEmpty)
        XCTAssertFalse(oneCall.current.weather.isEmpty)
        XCTAssertFalse(PreviewManager.weatherForecastData.list.isEmpty)
        XCTAssertFalse(PreviewManager.predictions.isEmpty)
        XCTAssertEqual(SavedPlace(details: PreviewManager.placeDetails).name, "Chicago")
        XCTAssertFalse(PreviewManager.geocode.name.isEmpty)
    }
}
