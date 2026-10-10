//
//  PlacesServiceTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest

@testable import AzureSkys

final class PlacesServiceTests: XCTestCase {
    func testPredictionQueryEncodingAndMissingResults() async throws {
        let network = RecordingNetwork { _ in Data(#"{"predictions":[{"place_id":"city","description":"City"}]}"#.utf8)
        }

        let service = PlacesService(networkManager: network, apiKeyManager: TestKeys())
        let predictions = try await service.getPredictions(query: "A&B + city")

        XCTAssertEqual(predictions.first?.placeId, "city")

        let url = try XCTUnwrap(network.urls.first)
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)!.queryItems!

        XCTAssertEqual(query.first { $0.name == "input" }?.value, "A&B + city")
        XCTAssertEqual(query.first { $0.name == "key" }?.value, "key&value")
        XCTAssertEqual(query.first { $0.name == "types" }?.value, "(cities)")
        XCTAssertTrue(url.path.hasSuffix("autocomplete/json"))

        let empty = PlacesService(networkManager: RecordingNetwork { _ in Data("{}".utf8) }, apiKeyManager: TestKeys())
        let result = try await empty.getPredictions(query: "city")

        XCTAssertTrue(result.isEmpty)
    }

    func testPlaceDetailsMappingAndIDEncoding() async throws {
        let network = RecordingNetwork { _ in
            Data(
                #"{"result":{"place_id":"city","name":"City","formatted_address":"City, USA","geometry":{"location":{"lat":12,"lng":34}},"address_components":[]}}"#
                    .utf8
            )
        }

        let place = try await PlacesService(networkManager: network, apiKeyManager: TestKeys()).getPlaceDetails(
            placeID: "id&value"
        )
        XCTAssertEqual(place.name, "City")
        XCTAssertEqual(place.latitude, 12)
        XCTAssertEqual(place.longitude, 34)

        let query = URLComponents(url: network.urls[0], resolvingAgainstBaseURL: false)!.queryItems!

        XCTAssertEqual(query.first { $0.name == "placeid" }?.value, "id&value")
        XCTAssertTrue(network.urls[0].path.hasSuffix("details/json"))
    }

    func testMissingKeysTransportFailureAndCancellation() async {
        let network = RecordingNetwork { _ in throw NetworkError.serverError }
        let keys = TestKeys()

        keys.fail = true

        let service = PlacesService(networkManager: network, apiKeyManager: keys)

        do {
            _ = try await service.getPredictions(query: "city")
            XCTFail("Expected key failure")
        } catch {
            XCTAssertEqual(error as? NetworkError, .badUrl)
        }

        keys.fail = false

        do {
            _ = try await service.getPlaceDetails(placeID: "city")
            XCTFail("Expected server failure")
        } catch {
            XCTAssertEqual(error as? NetworkError, .serverError)
        }

        let task = Task {
            try await Task.sleep(for: .seconds(1))

            return try await service.getPredictions(query: "canceled")
        }

        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }
}
