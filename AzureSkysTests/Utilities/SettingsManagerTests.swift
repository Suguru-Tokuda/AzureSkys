//
//  SettingsManagerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import UIKit
@testable import AzureSkys

@MainActor
final class SettingsManagerTests: XCTestCase {
    func testOpensSettingsOnlyWhenSupported() {
        var opened: [URL] = []
        let manager = SettingsManager(canOpen: { $0.absoluteString == UIApplication.openSettingsURLString }, open: { opened.append($0) })
        manager.navigateToSettings()
        XCTAssertEqual(opened.map(\.absoluteString), [UIApplication.openSettingsURLString])
        let blocked = SettingsManager(canOpen: { _ in false }, open: { opened.append($0) })
        blocked.navigateToSettings()
        XCTAssertEqual(opened.count, 1)
    }
}
