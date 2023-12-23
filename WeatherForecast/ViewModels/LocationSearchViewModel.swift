//
//  LocationSearchViewModel.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import Foundation
import MapKit
import Combine

class LocationSearchViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var predictions: [Prediction] = []
    @Published var errorOcurred: Bool = false
    @Published var customError: NetworkError?
    var cancellables = Set<AnyCancellable>()
    
    var networkManager: Networking
    var locationManager: LocationManager
    var apiKeyManager: ApiKeyActions
    
    init(networkManager: Networking = NetworkManager(), locationManager: LocationManager = LocationManager(), apiKeyManager: ApiKeyActions = ApiKeyManager()) {
        self.networkManager = networkManager
        self.locationManager = locationManager
        self.apiKeyManager = apiKeyManager
    }
    
    func addSubscriptions() {
        $searchText
            .receive(on: RunLoop.main)
            .sink { output in
                if !output.isEmpty {
                    self.getAutoCompletePlaces(query: output)
                }
            }
            .store(in: &cancellables)
    }
}

// api functions
extension LocationSearchViewModel {
    func getAutoCompletePlaces(query: String) {
        guard let apiKey = try? apiKeyManager.getGoogleApiKey(),
              let url = URL(string: "\(Constants.googleApiBaseURL)autocomplete/json?input=\(query)&type=%28cities%29&key=\(apiKey)") else { return }
        
        self.isLoading = true
        
        networkManager.getData(url: url, type: GoogleAutoCompleteModel.self)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                    break
                case .failure(let error):
                    if let error = error as? NetworkError {
                        self.customError = error
                    }
                    break
                }
            } receiveValue: { res in
                self.predictions = res.predictions ?? []
            }
            .store(in: &cancellables)
    }
    
    private func getPlaceDetails(placeId: String) async throws -> GooglePlaceDetails {
        guard let apiKey = try? apiKeyManager.getGoogleApiKey(),
              let url = URL(string: "\(Constants.googleApiBaseURL)details/json?placeid=\(placeId)&fields=geometry%2Cformatted_address%2Cname%2Cplace_id%2Caddress_components&key=\(apiKey)") else {
            throw NetworkError.badUrl
        }
        
        do {
            let res = try await networkManager.getData(url: url, type: GooglePlaceDetailsResponse.self)
            return res.result
        } catch {
            if let error = error as? NetworkError {
                self.customError = error
                self.errorOcurred = true
            }
            
            throw error
        }
    }
}
