//
//  WeatherServiceTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

import CoreLocation

final class WeatherServiceTests: XCTestCase {
    private let coordinate = CLLocationCoordinate2D(latitude: 12.5, longitude: -34.5)

    func testForecastAndReverseGeocodeUseSharedCoordinatesAndEncodedKey() async throws {
        let network = RecordingNetwork { url in
            url.path.contains("onecall") ? TestFixtures.oneCallData : Data(#"[{"name":"City","lat":12.5,"lon":-34.5,"country":"US"}]"#.utf8)
        }
        let result = try await WeatherService(networkManager: network, apiKeyManager: TestKeys()).getForecast(coordinate: coordinate)
        XCTAssertEqual(result.geocode?.name, "City")
        XCTAssertEqual(result.forecast.latitude, 12.5)
        XCTAssertEqual(network.urls.count, 2)
        for url in network.urls {
            let items = URLComponents(url: url, resolvingAgainstBaseURL: false)!.queryItems!
            XCTAssertEqual(items.first { $0.name == "lat" }?.value, "12.5")
            XCTAssertEqual(items.first { $0.name == "lon" }?.value, "-34.5")
            XCTAssertEqual(items.first { $0.name == "appid" }?.value, "weather&key")
        }
        let url = try XCTUnwrap(network.urls.first { $0.path.contains("onecall") })
        XCTAssertEqual(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "exclude" }?.value, "minutely")
    }

    func testEmptyGeocodeAndCurrentEndpoint() async throws {
        let network = RecordingNetwork { url in
            if url.path.contains("onecall") { return TestFixtures.oneCallData }
            if url.path.contains("reverse") { return Data("[]".utf8) }
            return TestFixtures.currentData
        }
        let service = WeatherService(networkManager: network, apiKeyManager: TestKeys())
        let forecast = try await service.getForecast(coordinate: coordinate)
        XCTAssertNil(forecast.geocode)
        let current = try await service.getCurrentWeather(coordinate: coordinate)
        XCTAssertEqual(current.name, "Test City")
        XCTAssertTrue(network.urls.contains { $0.path == "/data/2.5/weather" })
    }

    func testOfflineMissingKeyAndServerFailure() async {
        let network = RecordingNetwork { _ in throw NetworkError.serverError }
        let keys = TestKeys()
        let service = WeatherService(networkManager: network, apiKeyManager: keys)
        network.available = false
        do { _ = try await service.getForecast(coordinate: coordinate); XCTFail("Expected offline") } catch { XCTAssertEqual(error as? NetworkError, .networkUnavailable) }
        XCTAssertTrue(network.urls.isEmpty)
        network.available = true; keys.fail = true
        do { _ = try await service.getCurrentWeather(coordinate: coordinate); XCTFail("Expected missing key") } catch { XCTAssertEqual(error as? NetworkError, .badUrl) }
        keys.fail = false
        do { _ = try await service.getForecast(coordinate: coordinate); XCTFail("Expected server failure") } catch { XCTAssertEqual(error as? NetworkError, .serverError) }
    }
}
