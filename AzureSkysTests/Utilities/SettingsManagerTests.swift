//
//  SettingsManagerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import UIKit
import CoreLocation
@testable import AzureSkys

private final class SettingsLocationDriver: CLLocationManager {
    var status: CLAuthorizationStatus = .notDetermined
    var requestCount = 0

    override var authorizationStatus: CLAuthorizationStatus { status }
    override func requestWhenInUseAuthorization() {
        requestCount += 1
    }

    override func startUpdatingLocation() {}
    override func stopUpdatingLocation() {}
}

@MainActor
final class SettingsManagerTests: XCTestCase {
    func testLocationAccessRequestsFirstPermissionAndOpensSettingsAfterward() {
        let driver = SettingsLocationDriver()
        let location = LocationManager(locationManager: driver)
        var opened: [URL] = []
        let settings = SettingsManager(canOpen: { _ in true }, open: { opened.append($0) })

        XCTAssertEqual(location.authorizationStatus, .notDetermined)
        settings.manageLocationAccess(locationManager: location)
        XCTAssertEqual(driver.requestCount, 1)
        XCTAssertTrue(opened.isEmpty)

        for status in [CLAuthorizationStatus.denied, .authorizedWhenInUse, .authorizedAlways] {
            driver.status = status
            location.locationManagerDidChangeAuthorization(driver)
            XCTAssertEqual(location.authorizationStatus, status)
            settings.manageLocationAccess(locationManager: location)
        }

        XCTAssertEqual(opened.map(\.absoluteString), Array(repeating: UIApplication.openSettingsURLString, count: 3))
        driver.status = .restricted
        location.locationManagerDidChangeAuthorization(driver)
        settings.manageLocationAccess(locationManager: location)
        XCTAssertEqual(opened.count, 3)
        XCTAssertEqual(driver.requestCount, 1)
    }

    func testOpensSettingsOnlyWhenSupported() {
        var opened: [URL] = []
        let manager = SettingsManager(
            canOpen: { $0.absoluteString == UIApplication.openSettingsURLString },
            open: { opened.append($0) }
        )
        manager.navigateToSettings()
        XCTAssertEqual(opened.map(\.absoluteString), [UIApplication.openSettingsURLString])

        let blocked = SettingsManager(canOpen: { _ in false }, open: { opened.append($0) })

        blocked.navigateToSettings()
        XCTAssertEqual(opened.count, 1)
    }
}
