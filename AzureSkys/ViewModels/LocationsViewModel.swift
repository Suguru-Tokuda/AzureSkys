//
//  LocationsViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import SwiftUI

@MainActor
class LocationsViewModel: ObservableObject {
    @Published var errorOccured = false
    @Published var coreDataError: CoreDataError?
    
    var placeCoreDataManager: PlaceCoreDataManager
    
    init(placeCoreDataManager: PlaceCoreDataManager = PlaceCoreDataManager()) {
        self.placeCoreDataManager = placeCoreDataManager
    }
    
    func removeCity(results: FetchedResults<PlaceEntity>, indexSet: IndexSet) {
        for index in indexSet {
            let indexInt = Int(index)
            var place: GooglePlaceDetails?
            var i = 0
            
            results.forEach { entity in
                if i == indexInt {
                    place = GooglePlaceDetails(from: entity)
                }
                i += 1
            }
            
            if let place {
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        try await placeCoreDataManager.deleteFromDatabase(place: place)
                    } catch {
                        errorOccured = true
                        if let error = error as? CoreDataError {
                            coreDataError = error
                        }
                    }
                }
            }
        }
    }
    
    func dismissError() {
        errorOccured = false
        coreDataError = nil
    }
}
