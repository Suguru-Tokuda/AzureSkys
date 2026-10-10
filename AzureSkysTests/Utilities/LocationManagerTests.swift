//
//  LocationManagerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import CoreLocation
@testable import AzureSkys

// Controllable Core Location driver shared by location and view model tests.
final class LocationDriver: CLLocationManager {
    var status: CLAuthorizationStatus = .notDetermined
    var requested = false
    var started = false
    var stopped = false
    override var authorizationStatus: CLAuthorizationStatus { status }

    override func requestWhenInUseAuthorization() { requested = true }

    override func startUpdatingLocation() { started = true }
    override func stopUpdatingLocation() { stopped = true }
}

@MainActor
final class LocationManagerTests: XCTestCase {
    func testStartupAndPermissionMappingWithoutSystemPrompts() {
        let driver = LocationDriver()
        let manager = LocationManager(startAutomatically: true, locationManager: driver)
        XCTAssertTrue(driver.requested)
        XCTAssertFalse(driver.started)
        XCTAssertTrue(driver.delegate === manager)
        for (status, expected) in [(CLAuthorizationStatus.notDetermined, Optional<Bool>.none), (.restricted, false), (.denied, false), (.authorizedAlways, true), (.authorizedWhenInUse, true)] {
            driver.status = status
            manager.locationAuthorized = nil
            manager.locationManagerDidChangeAuthorization(driver)
            XCTAssertEqual(manager.locationAuthorized, expected)
        }
    }

    func testRelaunchWithExistingPermissionStartsUpdatesWithoutPrompt() {
        for status in [CLAuthorizationStatus.authorizedWhenInUse, .authorizedAlways] {
            let driver = LocationDriver()
            driver.status = status
            let manager = LocationManager(locationManager: driver)
            XCTAssertEqual(manager.locationAuthorized, true)
            XCTAssertTrue(driver.started)
            XCTAssertFalse(driver.requested)
        }
    }

    func testGrantingPermissionStartsUpdatesAfterOnboardingRequest() {
        let driver = LocationDriver()
        let manager = LocationManager(locationManager: driver)
        manager.requestAuthorization()
        XCTAssertTrue(driver.requested)
        XCTAssertFalse(driver.started)

        driver.status = .authorizedWhenInUse
        manager.locationManagerDidChangeAuthorization(driver)
        XCTAssertEqual(manager.locationAuthorized, true)
        XCTAssertTrue(driver.started)

        driver.status = .denied
        manager.locationManagerDidChangeAuthorization(driver)
        XCTAssertEqual(manager.locationAuthorized, false)
        XCTAssertTrue(driver.stopped)
    }

    func testLatestLocationAndDisabledAutomaticStart() {
        let driver = LocationDriver()
        let manager = LocationManager(startAutomatically: false, locationManager: driver)
        XCTAssertFalse(driver.requested)
        XCTAssertFalse(driver.started)
        let first = CLLocation(latitude: 1, longitude: 2), last = CLLocation(latitude: 3, longitude: 4)
        manager.locationManager(driver, didUpdateLocations: [first, last])
        XCTAssertEqual(manager.currentLocation, last)
        manager.locationManager(driver, didUpdateLocations: [])
        XCTAssertEqual(manager.currentLocation, last)
    }
}
