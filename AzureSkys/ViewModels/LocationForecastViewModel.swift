//
//  LocationForecastViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/5/23.
//

import Foundation
import Combine

@MainActor
class LocationForecastViewModel: ObservableObject {
    @Published var searchText = Strings.empty.rawValue
    @Published private(set) var searchState: RequestState<[Prediction]> = .idle
    @Published private(set) var detailsState: RequestState<SavedPlace> = .idle
    var predictions: [Prediction] { searchState.value ?? [] }
    var loadingStatus: LoadingStatus { searchState.loadingStatus }
    var networkError: NetworkError? { searchState.error }
    var detailsError: NetworkError? { detailsState.error }

    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var searchRequestID = UUID()
    
    private let placesService: PlacesServicing

    init(placesService: PlacesServicing) {
        self.placesService = placesService
        self.addSubscriptions()
    }

    deinit {
        searchTask?.cancel()
        cancellables.removeAll()
    }
    
    private func addSubscriptions() {
        $searchText
            .removeDuplicates()
            .sink { [weak self] query in
                self?.replaceSearch(query: query, debounce: true)
            }
            .store(in: &cancellables)
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
                guard !Task.isCancelled, self?.searchRequestID == requestID else { return }
                self?.searchState = .failed(NetworkError(error))
            }
        }
    }

    func getPlaceDetails(placeId: String) async -> SavedPlace? {
        if case .loading = detailsState { return nil }
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
