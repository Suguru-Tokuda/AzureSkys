//
//  ControlledPlacesService.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import Foundation
@testable import AzureSkys

actor ControlledPlacesService: PlacesServicing {
    private var requests: [String: CheckedContinuation<[Prediction], Error>] = [:]
    private var waiters: [String: CheckedContinuation<Void, Never>] = [:]

    func getPredictions(query: String) async throws -> [Prediction] {
        try await withCheckedThrowingContinuation { continuation in
            requests[query] = continuation
            waiters.removeValue(forKey: query)?.resume()
        }
    }

    func waitForRequest(_ query: String) async {
        if requests[query] != nil {
            return
        }

        await withCheckedContinuation { waiters[query] = $0 }
    }

    func finish(_ query: String, error: NetworkError? = nil) {
        let continuation = requests.removeValue(forKey: query)

        if let error {
            continuation?.resume(throwing: error)
        } else {
            continuation?.resume(returning: [.init(id: UUID(), description: query, placeId: query)])
        }
    }

    func getPlaceDetails(placeID: String) async throws -> SavedPlace {
        throw URLError(.notConnectedToInternet)
    }
}
