//
//  RequestStateTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import XCTest
@testable import AzureSkys

final class RequestStateTests: XCTestCase {
    func testQuietRefreshPreservesDataAndDismissalRestoresIt() {
        var state: RequestState<Int> = .loaded(42)
        state = .loading(previous: state.value)
        XCTAssertEqual(state.value, 42)
        XCTAssertEqual(state.loadingStatus, .loaded)
        state = .failed(.networkUnavailable, previous: state.value)
        XCTAssertEqual(state.error, .networkUnavailable)
        state.dismissError()
        XCTAssertNil(state.error)
        XCTAssertEqual(state.value, 42)
        XCTAssertEqual(state.loadingStatus, .loaded)
    }

    func testInitialLoadingAndErrorDismissalWithoutData() {
        var state: RequestState<Int> = .loading()
        XCTAssertNil(state.value)
        XCTAssertEqual(state.loadingStatus, .loading)
        state = .failed(.serverError)
        state.dismissError()
        XCTAssertEqual(state.loadingStatus, .inactive)
    }

    func testErrorMappingPreservesKnownErrorsAndRecognizesOffline() {
        XCTAssertEqual(NetworkError(NetworkError.noData), .noData)
        XCTAssertEqual(NetworkError(URLError(.notConnectedToInternet)), .networkUnavailable)
        XCTAssertEqual(NetworkError(URLError(.networkConnectionLost)), .networkUnavailable)
        XCTAssertEqual(NetworkError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "invalid"))), .dataParsingError)
    }
}
