//
//  WeatherImageViewTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
import UIKit
@testable import AzureSkys

@MainActor
final class WeatherImageViewTests: XCTestCase {
    func testRendersVisibleContentWithFixtureData() async throws {
        assertVisibleContent(try await renderSnapshot(WeatherImageView(icon: "01d", width: 40)))
    }

    func testDownloadedImageAndInvalidResponsesRenderDifferently() async throws {
        let png = UIGraphicsImageRenderer(size: CGSize(width: 12, height: 12)).image { context in
            UIColor.red.setFill(); context.fill(CGRect(x: 0, y: 0, width: 12, height: 12))
        }.pngData()!
        let downloaded = try await scenario(status: 200, data: png)
        for (status, data) in [(404, png), (200, Data("invalid".utf8))] {
            let fallback = try await scenario(status: status, data: data)
            XCTAssertNotEqual(downloaded.pngData(), fallback.pngData())
            assertVisibleContent(fallback)
        }
        let offline = try await scenario(status: 200, data: Data(), failure: URLError(.notConnectedToInternet))
        XCTAssertNotEqual(downloaded.pngData(), offline.pngData())
    }

    func testCacheErrorsStillAllowValidDownload() async throws {
        let png = UIImage(systemName: "sun.max")!.withTintColor(.yellow, renderingMode: .alwaysOriginal).pngData()!
        let image = try await scenario(status: 200, data: png, cache: FailingImageCache(directory: nil))
        assertVisibleContent(image)
    }

    private func scenario(status: Int, data: Data, failure: URLError? = nil, cache: LocalFileManager? = nil) async throws -> UIImage {
        StubURLProtocol.response = (status, data); StubURLProtocol.failure = failure
        defer { StubURLProtocol.failure = nil }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        return try await renderSnapshot(WeatherImageView(icon: "test-" + UUID().uuidString, width: 40, session: session), fileManager: cache)
    }

}

private final class FailingImageCache: LocalFileManager {
    override func getImage(name: String) throws -> UIImage? { throw FileManagerError.retrieve }

    override func saveImage(image: UIImage, name: String) throws { throw FileManagerError.save }
}
