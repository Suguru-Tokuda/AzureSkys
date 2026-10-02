//
//  LocationsViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import SwiftUI

@MainActor
class LocationsViewModel: ObservableObject {
    @Published var coreDataError: CoreDataError?
    
    private let placeCoreDataManager: PlaceCoreDataActions
    
    init(placeCoreDataManager: PlaceCoreDataActions) {
        self.placeCoreDataManager = placeCoreDataManager
    }
    
    func removeCity(results: FetchedResults<PlaceEntity>, indexSet: IndexSet) {
        coreDataError = nil
        // Capture the selected places before deletions update the fetched results.
        let places = indexSet.compactMap { SavedPlace(from: results[$0]) }
        Task { [weak self] in
            guard let self else { return }
            for place in places {
                do {
                    try await placeCoreDataManager.deleteFromDatabase(place: place)
                } catch {
                    coreDataError = .delete
                }
            }
        }
    }
    
    func dismissError() {
        coreDataError = nil
    }
}
