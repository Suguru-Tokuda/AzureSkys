//
//  LocationListView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/7/23.
//

import SwiftUI
import CoreData

struct LocationListView: View {
    @EnvironmentObject var mainCoordinator: MainCoordinator
    @Environment(\.isSearching) private var isSearching
    @StateObject var vm: LocationsViewModel = LocationsViewModel()
    @FetchRequest(entity: CityEntity.entity(), sortDescriptors: [])
    var results: FetchedResults<CityEntity>
    var request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
    var onCitySelect: ((City?) -> Void)?
    
    var body: some View {
        ZStack {
            if isSearching {
                Color
                    .black
                    .opacity(0.4)
                    .zIndex(2)
            }
            
            List {
                LocationViewCell(isMyLocation: true)
                    .deleteDisabled(true)
                    .onTapGesture {
                        onCitySelect?(nil)
                    }
                ForEach(results) { cityEntity in
                    LocationViewCell(city: City(from: cityEntity))
                        .onTapGesture {
                            onCitySelect?(City(from: cityEntity))
                        }
                }
                .onDelete { indexSet in
                    vm.removeCity(results: results, indexSet: indexSet)
                }
            }
            .listStyle(.plain)
            .zIndex(1)
        }
    }
}

#Preview {
    LocationListView()
        .preferredColorScheme(.dark)
        .environmentObject(LocationManager())
        .environmentObject(MainCoordinator())
}
