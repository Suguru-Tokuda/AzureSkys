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
    @Published var isErrorOccured = false
    @Published var networkError: NetworkError?
    @Published var predictions: [Prediction] = []
    
    var gettingDetails: Bool = false
    var cancellables = Set<AnyCancellable>()
    
    let networkManager: NetworkManager
    let apiKeyManager: ApiKeyActions
    
    init(networkManager: NetworkManager = NetworkManager(), apiKeyManager: ApiKeyActions = ApiKeyManager()) {
        self.networkManager = networkManager
        self.apiKeyManager = apiKeyManager
        self.addSubscriptions()
        
        self.networkManager.checkNetworkAvailability(queue: DispatchQueue.global(qos: .background)) { [weak self] networkAvailable in
            guard let self else { return }
            DispatchQueue.main.async {
                self.networkError = !networkAvailable ? NetworkError.networkUnavailable : nil
            }
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    func addSubscriptions() {
        $searchText
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { val in
                Task {
                    await self.getPredictions(searchText: val)
                }
            }
            .store(in: &cancellables)
    }
    
    func dismissError() {
        self.networkError = nil
        self.isErrorOccured = false
    }
    
    func getPredictions(searchText: String) async {
        if !searchText.isEmpty && isLoading == .inactive {
            guard let urlStr = getGooglePlacesPrediction(searchText: searchText),
                  let url = URL(string: urlStr) else {
                isErrorOccured = true
                networkError = NetworkError.badUrl
                return
            }
            
            isLoading = .loading
            
            do {
                let res = try await self.networkManager.getData(url: url, type: GoogleAutoCompleteModel.self)
                
                self.predictions = res.predictions ?? []
                self.isLoading = .inactive
            } catch {
                self.isLoading = .inactive
                await handleGetWeatherForecastError(error: error)
            }
        }
    }
    
    func getPlaceDetails(placeId: String) async -> GooglePlaceDetails? {
        if !gettingDetails {
            guard let urlStr = getGoogleDetailsURL(placeId: placeId),
                  let url = URL(string: urlStr) else {
                isErrorOccured = true
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
                await handleGetWeatherForecastError(error: error)
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func handleGetWeatherForecastError(error: Error) async {
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
        
        isErrorOccured = true
    }
    
    private func getGooglePlacesPrediction(searchText: String, endPoint: String = Constants.googleApiBaseURL) -> String? {
        guard let apiKey = try? apiKeyManager.getGoogleApiKey() else { return nil }
        return "\(endPoint)autocomplete/json?input=\(searchText.replacingOccurrences(of: " ", with: "+"))&types=%28cities%29&fields=place_id%29description&key=\(apiKey)"
    }
    
    private func getGoogleDetailsURL(placeId: String, endPoint: String = Constants.googleApiBaseURL) -> String? {
        guard let apiKey = try? apiKeyManager.getGoogleApiKey() else { return nil }
        return "\(endPoint)details/json?placeid=\(placeId)&fields=geometry%2Cformatted_address%2Cname%2Cplace_id%2Caddress_components&key=\(apiKey)"
    }
}
