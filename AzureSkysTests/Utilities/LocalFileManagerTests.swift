//
//  LocalFileManagerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import UIKit
@testable import AzureSkys

@MainActor
final class LocalFileManagerTests: XCTestCase {
    func testImageRoundTripAndMissingOrCorruptCache() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let manager = LocalFileManager(directory: directory)
        let image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { context in UIColor.red.setFill(); context.fill(CGRect(x: 0, y: 0, width: 10, height: 10)) }
        try manager.saveImage(image: image, name: "test.png")
        let loaded = try XCTUnwrap(manager.getImage(name: "test.png"))
        XCTAssertEqual(loaded.cgImage?.width, image.cgImage?.width)
        XCTAssertEqual(loaded.cgImage?.height, image.cgImage?.height)
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        defer { bytes.deallocate() }
        let context = CGContext(data: bytes, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.draw(loaded.cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertEqual(bytes[0], 255)
        XCTAssertEqual(bytes[1], 0)
        XCTAssertEqual(bytes[2], 0)
        XCTAssertThrowsError(try manager.getImage(name: "missing.png")) { XCTAssertEqual($0 as? FileManagerError, .retrieve) }
        try Data("invalid".utf8).write(to: directory.appendingPathComponent("corrupt.png"))
        XCTAssertNil(try manager.getImage(name: "corrupt.png"))
        XCTAssertEqual(manager.getPath(name: "test.png"), directory.appendingPathComponent("test.png"))
    }

    func testUnavailableDirectoryAndWriteFailure() {
        let manager = LocalFileManager(directory: nil)
        XCTAssertNil(manager.getPath(name: "test"))
        XCTAssertThrowsError(try manager.getImage(name: "test")) { XCTAssertEqual($0 as? FileManagerError, .badPath) }
        let image = UIImage(systemName: "cloud")!
        XCTAssertThrowsError(try manager.saveImage(image: image, name: "test")) { XCTAssertEqual($0 as? FileManagerError, .badPath) }
        let unavailable = LocalFileManager(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        XCTAssertThrowsError(try unavailable.saveImage(image: image, name: "test")) { XCTAssertEqual($0 as? FileManagerError, .save) }
        XCTAssertThrowsError(try manager.saveImage(image: UIImage(), name: "test")) { XCTAssertEqual($0 as? FileManagerError, .data) }
    }
}
