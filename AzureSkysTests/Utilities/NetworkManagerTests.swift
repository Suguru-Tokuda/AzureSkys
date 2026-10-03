//
//  NetworkManagerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import XCTest
import Combine
@testable import AzureSkys

final class NetworkManagerTests: XCTestCase {
    private struct Payload: Decodable { let value: Int }
    private var session: URLSession!
    private var manager: NetworkManager!
    private let url = URL(string: "https://example.test/forecast")!

    override func setUp() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        session = URLSession(configuration: configuration)
        manager = NetworkManager(session: session)
        StubURLProtocol.failure = nil
        StubURLProtocol.response = (200, Data())
    }

    override func tearDown() {
        session.invalidateAndCancel()
        session = nil
        manager = nil
    }

    func testSuccessfulResponseDecodes() async throws {
        StubURLProtocol.response = (200, Data(#"{"value":42}"#.utf8))
        let result = try await manager.getData(url: url, type: Payload.self)
        XCTAssertEqual(result.value, 42)
    }

    func testHTTPFailureIsRejectedBeforeDecoding() async {
        StubURLProtocol.response = (500, Data(#"{"value":42}"#.utf8))
        await assertFailure(.serverError)
    }

    func testEmptyResponseReportsNoData() async {
        await assertFailure(.noData)
    }

    func testMalformedResponseReportsParsingError() async {
        StubURLProtocol.response = (200, Data("invalid".utf8))
        await assertFailure(.dataParsingError)
    }

    func testTransportErrorIsPreserved() async {
        StubURLProtocol.failure = URLError(.notConnectedToInternet)
        do {
            _ = try await manager.getData(url: url, type: Payload.self)
            XCTFail("Expected transport failure")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
        }
    }

    private func assertFailure(_ expected: NetworkError) async {
        do {
            _ = try await manager.getData(url: url, type: Payload.self)
            XCTFail("Expected \(expected)")
        } catch {
            XCTAssertEqual(error as? NetworkError, expected)
        }
    }

    func testNilURLFailsForAsyncAndCallbackAPIs() async {
        do { _ = try await manager.getData(url: nil, type: Payload.self); XCTFail("Expected bad URL") }
        catch { XCTAssertEqual(error as? NetworkError, .badUrl) }
        let result: Result<Payload, Error> = await withCheckedContinuation { continuation in
            manager.getData(url: nil, type: Payload.self) { continuation.resume(returning: $0) }
        }
        if case .failure(let error) = result { XCTAssertEqual(error as? NetworkError, .badUrl) }
        else { XCTFail("Expected callback failure") }
    }

    func testCallbackDecodesAndPreservesTransportErrors() async throws {
        StubURLProtocol.response = (200, Data(#"{"value":7}"#.utf8))
        let success = await callbackResult()
        XCTAssertEqual(try success.get().value, 7)
        StubURLProtocol.failure = URLError(.timedOut)
        let failure = await callbackResult()
        if case .failure(let error) = failure { XCTAssertEqual((error as? URLError)?.code, .timedOut) }
        else { XCTFail("Expected transport failure") }
    }

    func testPublisherValidatesHTTPAndDecodesSuccess() async {
        for code in [200, 500] {
            StubURLProtocol.response = (code, Data(#"{"value":9}"#.utf8))
            let completed = expectation(description: "Publisher completion")
            let publisher: AnyPublisher<Payload, Error> = manager.getData(url: url, type: Payload.self)
            let subscription = publisher.sink { result in
                if case .failure(let error) = result { XCTAssertEqual(error as? NetworkError, .serverError) }
                else { XCTAssertEqual(code, 200) }
                completed.fulfill()
            } receiveValue: { payload in
                XCTAssertEqual(code, 200)
                XCTAssertEqual(payload.value, 9)
            }
            await fulfillment(of: [completed], timeout: 2)
            withExtendedLifetime(subscription) {}
        }
    }

    func testReachabilityCompletesOnceForCallbackAndAsyncAPIs() async {
        let completed = expectation(description: "First local path update")
        completed.assertForOverFulfill = true
        manager.checkNetworkAvailability(queue: DispatchQueue(label: "ReachabilityTests")) { _ in completed.fulfill() }
        await fulfillment(of: [completed], timeout: 3)
        _ = await manager.checkNetworkAvailability(queue: DispatchQueue(label: "AsyncReachabilityTests"))
    }

    private func callbackResult() async -> Result<Payload, Error> {
        await withCheckedContinuation { continuation in
            manager.getData(url: url, type: Payload.self) { continuation.resume(returning: $0) }
        }
    }

}
