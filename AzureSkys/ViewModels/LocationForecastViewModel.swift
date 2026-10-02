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
    @Published var searchText = ""
    @Published var isLoading: LoadingStatus = .inactive
    @Published var hasError = false
    @Published var networkError: NetworkError?
    @Published var predictions: [Prediction] = []
    
    var gettingDetails: Bool = false
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
        self.networkError = nil
        self.hasError = false
    }
    
    func getPredictions(searchText: String) async {
        replaceSearch(query: searchText, debounce: false)
        await searchTask?.value
    }

    private func replaceSearch(query: String, debounce: Bool) {
        searchTask?.cancel()
        let requestID = UUID()
        searchRequestID = requestID
        predictions = []
        isLoading = .inactive
        dismissError()

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
                self?.isLoading = .loading
                let predictions = try await placesService.getPredictions(query: query)
                try Task.checkCancellation()
                guard self?.searchRequestID == requestID else { return }

                self?.predictions = predictions
                self?.isLoading = .inactive
                self?.dismissError()
            } catch {
                guard !Task.isCancelled, self?.searchRequestID == requestID else { return }
                self?.isLoading = .inactive
                self?.handleGetWeatherForecastError(error: error)
            }
        }
    }

    func getPlaceDetails(placeId: String) async -> SavedPlace? {
        guard !gettingDetails else { return nil }
        gettingDetails = true
        defer { gettingDetails = false }

        do {
            return try await placesService.getPlaceDetails(placeID: placeId)
        } catch {
            guard !Task.isCancelled else { return nil }
            handleGetWeatherForecastError(error: error)
            return nil
        }
    }

    private func handleGetWeatherForecastError(error: Error) {
        switch error {
        case NetworkError.badUrl:
            networkError = NetworkError.badUrl
        case NetworkError.dataParsingError:
            networkError = NetworkError.dataParsingError
        case NetworkError.noData:
            networkError = NetworkError.noData
        case NetworkError.serverError:
            networkError = NetworkError.serverError
        case NetworkError.unknown:
            networkError = NetworkError.unknown
        default:
            networkError = NetworkError.unknown
        }
        
        hasError = true
    }
}
