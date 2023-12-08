//
//  LocationsViewModel.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/7/23.
//

import SwiftUI

@MainActor
class LocationsViewModel: ObservableObject {
    @Published var errorOccured = false
    @Published var customError: Error?
    
    var cityCoreDataManager: CityCoreDataManager
    
    init(cityCoreDataManager: CityCoreDataManager = CityCoreDataManager()) {
        self.cityCoreDataManager = cityCoreDataManager
    }
    
    func removeCity(results: FetchedResults<CityEntity>, indexSet: IndexSet) {
        for index in indexSet {
            let indexInt = Int(index)
            var city: City?
            var i = 0
            
            results.forEach { entity in
                if i == indexInt {
                    city = City(from: entity)
                }
                i += 1
            }
            
            if let city {
                Task {
                    do {
                        try await cityCoreDataManager.deleteFromDatabase(city: city)
                    } catch {
                        errorOccured = true
                        customError = error
                    }
                }

            }
        }
    }    
}
