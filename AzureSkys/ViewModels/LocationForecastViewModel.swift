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
    
    let networkManager: Networking
    let apiKeyManager: ApiKeyActions
    
    init(networkManager: Networking = NetworkManager(), apiKeyManager: ApiKeyActions = ApiKeyManager()) {
        self.networkManager = networkManager
        self.apiKeyManager = apiKeyManager
        self.addSubscriptions()
        
        self.networkManager.checkNetworkAvailability(queue: DispatchQueue.global(qos: .background)) { [weak self] networkAvailable in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                self?.networkError = !networkAvailable ? NetworkError.networkUnavailable : nil
            }
        }
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

        searchTask = Task { [weak self, networkManager] in
            do {
                // Cancel as soon as input changes, including during the debounce.
                if debounce {
                    try await Task.sleep(for: .seconds(1))
                }
                try Task.checkCancellation()
                guard self?.searchRequestID == requestID else { return }
                guard let urlString = self?.getGooglePlacesPrediction(searchText: query),
                      let url = URL(string: urlString) else {
                    throw NetworkError.badUrl
                }

                self?.isLoading = .loading
                let response = try await networkManager.getData(url: url, type: GoogleAutoCompleteModel.self)
                try Task.checkCancellation()
                guard self?.searchRequestID == requestID else { return }

                self?.predictions = response.predictions ?? []
                self?.isLoading = .inactive
                self?.dismissError()
            } catch {
                guard !Task.isCancelled, self?.searchRequestID == requestID else { return }
                self?.isLoading = .inactive
                self?.handleGetWeatherForecastError(error: error)
            }
        }
    }

    func getPlaceDetails(placeId: String) async -> GooglePlaceDetails? {
        if !gettingDetails {
            guard let urlStr = getGoogleDetailsURL(placeId: placeId),
                  let url = URL(string: urlStr) else {
                hasError = true
                networkError = NetworkError.badUrl
                return nil
            }
            
            gettingDetails = true
            
            do {
                let res = try await self.networkManager.getData(url: url, type: GooglePlaceDetailsResponse.self)
                
                self.gettingDetails = false
                return res.result
            } catch {
                self.gettingDetails = false
                handleGetWeatherForecastError(error: error)
                return nil
            }
        } else {
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
    
    private func getGooglePlacesPrediction(searchText: String, endPoint: String = Constants.googleApiBaseURL) -> String? {
        guard let apiKey = try? apiKeyManager.getGoogleApiKey() else { return nil }
        guard var components = URLComponents(string: endPoint + "autocomplete/json") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "input", value: searchText),
            URLQueryItem(name: "types", value: "(cities)"),
            URLQueryItem(name: "fields", value: "place_id,description"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        return components.url?.absoluteString
    }
    
    private func getGoogleDetailsURL(placeId: String, endPoint: String = Constants.googleApiBaseURL) -> String? {
        guard let apiKey = try? apiKeyManager.getGoogleApiKey() else { return nil }
        return "\(endPoint)details/json?placeid=\(placeId)&fields=geometry%2Cformatted_address%2Cname%2Cplace_id%2Caddress_components&key=\(apiKey)"
    }
}
