//
//  LocationForecastViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/5/23.
//

import Foundation
import Observation

@MainActor
@Observable
class LocationForecastViewModel {
    var searchText = "" {
        didSet {
            guard searchText != oldValue else { return }
            replaceSearch(query: searchText, debounce: true)
        }
    }
    var predictions: [Prediction] { searchState.value ?? [] }
    var loadingStatus: LoadingStatus { searchState.loadingStatus }
    var networkError: NetworkError? { searchState.error }
    var detailsError: NetworkError? { detailsState.error }
    private var searchState: RequestState<[Prediction]> = .idle
    private var detailsState: RequestState<SavedPlace> = .idle

    @ObservationIgnored private var searchTask: Task<Void, Never>?
    @ObservationIgnored private var searchRequestID = UUID()
    private let placesService: PlacesServicing

    init(placesService: PlacesServicing) {
        self.placesService = placesService
    }

    deinit {
        searchTask?.cancel()
    }

    func retrySearch() async {
        guard !searchText.isEmpty else { return }

        await getPredictions(searchText: searchText)
    }

    func dismissError() {
        detailsState.dismissError()
    }

    func getPredictions(searchText: String) async {
        replaceSearch(query: searchText, debounce: false)
        await searchTask?.value
    }

    private func replaceSearch(query: String, debounce: Bool) {
        searchTask?.cancel()

        let requestID = UUID()

        searchRequestID = requestID
        searchState = .idle
        detailsState = .idle

        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            searchTask = nil

            return
        }

        searchTask = Task { [weak self, placesService] in
            do {
                // Cancel as soon as input changes, including during the debounce.

                if debounce {
                    try await Task.sleep(for: .seconds(1))
                }

                try Task.checkCancellation()

                guard self?.searchRequestID == requestID else { return }

                self?.searchState = .loading()

                let predictions = try await placesService.getPredictions(query: query)

                try Task.checkCancellation()

                guard self?.searchRequestID == requestID else { return }

                self?.searchState = .loaded(predictions)
            } catch {
                guard !Task.isCancelled, self?.searchRequestID == requestID else {
                    return
                }

                self?.searchState = .failed(NetworkError(error))
            }
        }
    }

    func getPlaceDetails(placeId: String) async -> SavedPlace? {
        if case .loading = detailsState {
            return nil
        }

        let requestID = searchRequestID

        detailsState = .loading()

        do {
            let place = try await placesService.getPlaceDetails(placeID: placeId)

            try Task.checkCancellation()

            guard searchRequestID == requestID else { return nil }

            detailsState = .loaded(place)

            return place
        } catch {
            guard searchRequestID == requestID else { return nil }

            guard !Task.isCancelled else {
                detailsState = .idle

                return nil
            }

            detailsState = .failed(NetworkError(error))

            return nil
        }
    }

}

// MARK: Test hooks

#if DEBUG
extension LocationForecastViewModel {
    /// Exposes private state to unit tests without widening its access level.
    @MainActor
    struct TestHooks {
        fileprivate let target: LocationForecastViewModel

        var searchState: RequestState<[Prediction]> { target.searchState }
        var detailsState: RequestState<SavedPlace> { target.detailsState }
        var hasActiveSearch: Bool { target.searchTask != nil }
    }

    var testHooks: TestHooks { TestHooks(target: self) }
}
#endif
