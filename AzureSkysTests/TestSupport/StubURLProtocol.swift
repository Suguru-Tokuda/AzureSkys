//
//  StubURLProtocol.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import Foundation
@testable import AzureSkys

final class StubURLProtocol: URLProtocol {
    static var response: (Int, Data) = (200, Data())
    static var failure: URLError?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        if let failure = Self.failure {
            client?.urlProtocol(self, didFailWithError: failure)

            return
        }

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: Self.response.0,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.response.1)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
