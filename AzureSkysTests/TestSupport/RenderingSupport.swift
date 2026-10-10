//
//  RenderingSupport.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

import SwiftUI
import UIKit

@MainActor
func renderSnapshot<V: View>(_ view: V, dependencies: AppDependencies? = nil, fileManager: LocalFileManager? = nil)
    async throws -> UIImage
{
    let dependencies = dependencies ?? AppDependencies.preview()
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

    defer {
        try? FileManager.default.removeItem(at: directory)
    }

    let cache = fileManager ?? LocalFileManager(directory: directory)
    // Seed icons so rendering tests never access the network.
    let icon = UIGraphicsImageRenderer(size: CGSize(width: 12, height: 12)).image { context in
        UIColor.white.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 12, height: 12))
    }

    if fileManager == nil {
        for code in ["01d", "01n", "02d", "03d", "04d", "10d", "13d"] {
            try cache.saveImage(image: icon, name: code)
        }
    }

    let suiteName = "AzureSkys.Rendering." + UUID().uuidString
    let defaults = UserDefaults(suiteName: suiteName)!

    defer {
        defaults.removePersistentDomain(forName: suiteName)
    }

    defaults.set(TempScale.fahrenheit.rawValue, forKey: UserDefaultKeys.tempScale.rawValue)

    let root = view.appEnvironment(dependencies).environmentObject(cache)
        .defaultAppStorage(defaults)
        .preferredColorScheme(.dark)
    let controller = UIHostingController(rootView: root)
    let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
    let window = UIWindow(windowScene: scene)

    window.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
    window.rootViewController = controller
    window.makeKeyAndVisible()

    defer {
        window.isHidden = true
        window.rootViewController = nil
    }

    controller.view.frame = window.bounds
    controller.view.backgroundColor = UIColor.black
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
    try await Task.sleep(for: .milliseconds(60))
    controller.view.layoutIfNeeded()

    return UIGraphicsImageRenderer(size: window.bounds.size).image { _ in
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
    }
}

@MainActor
func assertVisibleContent(_ image: UIImage, file: StaticString = #filePath, line: UInt = #line) {
    guard let cgImage = image.cgImage, let data = cgImage.dataProvider?.data, let bytes = CFDataGetBytePtr(data) else {
        XCTFail("Snapshot has no pixels", file: file, line: line)

        return
    }

    var colors = Set<UInt32>()

    for offset in stride(from: 0, to: CFDataGetLength(data) - 4, by: 4) {
        colors.insert(UInt32(bytes[offset]) << 16 | UInt32(bytes[offset + 1]) << 8 | UInt32(bytes[offset + 2]))

        if colors.count > 8 {
            break
        }
    }

    XCTAssertGreaterThan(colors.count, 1, "View should draw content beyond a blank background", file: file, line: line)
}

@MainActor
func assertDifferent<V: View, W: View>(_ first: V, _ second: W, file: StaticString = #filePath, line: UInt = #line)
    async throws
{
    let a = try await renderSnapshot(first), b = try await renderSnapshot(second)

    XCTAssertNotEqual(
        a.pngData(),
        b.pngData(),
        "Changing displayed state should change rendered output",
        file: file,
        line: line
    )
}
