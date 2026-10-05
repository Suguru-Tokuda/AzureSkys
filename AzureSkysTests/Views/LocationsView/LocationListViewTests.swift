//
//  LocationListViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
import UIKit
@testable import AzureSkys

@MainActor
final class LocationListViewTests: XCTestCase {
    func testVisibleLocationListSurvivesRepeatedStoreReplacement() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let persistence = PersistenceController(storeURL: directory.appendingPathComponent("places.sqlite"))
        let store = PlaceCoreDataManager(persistence: persistence)
        let preview = AppDependencies.preview()
        let dependencies = AppDependencies(
            weatherService: preview.weatherService, placesService: preview.placesService,
            placeStore: store, persistenceController: persistence,
            locationManager: preview.locationManager, coordinator: preview.coordinator,
            fileManager: preview.fileManager, settingsManager: preview.settingsManager,
            iCloudManager: ICloudManager(persistence: persistence)
        )
        try await store.savePlaceIntoDatabase(place: testPlace)
        let snapshots = try await store.getPlacesFromDatabase()
        let controller = UIHostingController(rootView: LocationListView(dependencies: dependencies).appEnvironment(dependencies))
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil }

        for _ in 0..<4 {
            try await Task.sleep(for: .milliseconds(100))
            controller.view.layoutIfNeeded()
            let previousContext = persistence.viewContext
            // Exercise the same teardown/replacement without requiring a CloudKit account.
            try await persistence.reloadStore(syncEnabled: false)
            XCTAssertFalse(previousContext === persistence.viewContext)
            let places = try await store.getPlacesFromDatabase()
            XCTAssertEqual(places, snapshots)
            controller.view.layoutIfNeeded()
        }
        try await store.deleteFromDatabase(place: snapshots[0])
        let remaining = try await store.getPlacesFromDatabase()
        XCTAssertTrue(remaining.isEmpty)
        try await Task.sleep(for: .milliseconds(100))
        controller.view.layoutIfNeeded()
    }

    func testRendersWithInjectedDependencies() async throws {
        let dependencies = AppDependencies.preview()
        assertVisibleContent(try await renderSnapshot(LocationListView(dependencies: dependencies), dependencies: dependencies))
    }
}
