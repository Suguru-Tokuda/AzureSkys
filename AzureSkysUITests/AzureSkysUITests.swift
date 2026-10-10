//
//  AzureSkysUITests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import XCTest

@MainActor
final class AzureSkysUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    private func openLocations() {
        app.launch()

        let chooseCities = app.buttons["Choose Cities Instead"]

        if chooseCities.waitForExistence(timeout: 3) {
            chooseCities.tap()

            let notNow = app.buttons["Not Now"]

            XCTAssertTrue(notNow.waitForExistence(timeout: 5))
            notNow.tap()
        }

        let locations = app.buttons["locationsButton"]

        XCTAssertTrue(locations.waitForExistence(timeout: 10))
        locations.tap()
        XCTAssertTrue(app.navigationBars["Weather"].waitForExistence(timeout: 5))
    }

    private func search() {
        let field = app.searchFields.firstMatch

        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("Chicago")
    }

    func testSettingsTemperatureSelectionAndBackNavigation() {
        openLocations()
        app.buttons["Settings"].tap()

        let celsius = app.buttons["Celsius"]

        XCTAssertTrue(celsius.waitForExistence(timeout: 5))
        celsius.tap()
        XCTAssertTrue(celsius.isSelected)
        XCTAssertFalse(app.buttons["Fahrenheit"].isSelected)

        let attachment = XCTAttachment(screenshot: app.screenshot())

        attachment.name = "Settings weather cards"
        attachment.lifetime = .keepAlways
        add(attachment)

        app.buttons["Back"].tap()
        XCTAssertTrue(app.navigationBars["Weather"].waitForExistence(timeout: 5))
        app.buttons["Settings"].tap()
        XCTAssertTrue(celsius.waitForExistence(timeout: 5))
        XCTAssertTrue(celsius.isSelected)
        app.buttons["Fahrenheit"].tap()
        XCTAssertTrue(app.buttons["Fahrenheit"].isSelected)
    }

    func testLocationsDismissReturnsToForecast() {
        openLocations()
        app.buttons["dismissButton"].tap()
        XCTAssertTrue(app.buttons["locationsButton"].waitForExistence(timeout: 5))
    }

    func testCancelPreviewDoesNotSavePlace() {
        openLocations()
        search()

        let prediction = app.staticTexts["Chicago IL, USA"].firstMatch

        XCTAssertTrue(prediction.waitForExistence(timeout: 5))
        prediction.tap()
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Weather"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Chicago"].exists)
    }

    func testAddPlaceAppearsInListAndCanBeSelected() {
        openLocations()
        search()

        let prediction = app.staticTexts["Chicago IL, USA"].firstMatch

        XCTAssertTrue(prediction.waitForExistence(timeout: 5))
        prediction.tap()

        let add = app.buttons["Add"]

        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.tap()

        let saved = app.staticTexts["Chicago"].firstMatch

        XCTAssertTrue(saved.waitForExistence(timeout: 5))
        saved.tap()
        XCTAssertTrue(app.buttons["locationsButton"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.navigationBars["Weather"].exists)
    }

    func testSearchFailureCanBeRetried() {
        app.launchArguments.append("--search-fails-once")
        openLocations()
        search()

        let retry = app.buttons["Retry"]

        XCTAssertTrue(retry.waitForExistence(timeout: 5))
        retry.tap()
        XCTAssertTrue(app.staticTexts["Chicago IL, USA"].firstMatch.waitForExistence(timeout: 5))
    }
}
