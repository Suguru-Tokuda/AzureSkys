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
    @FetchRequest(entity: PlaceEntity.entity(), sortDescriptors: [])
    var results: FetchedResults<PlaceEntity>
    var request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
    var onCitySelect: ((GooglePlaceDetails?) -> Void)?
    
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
                ForEach(results) { placeEntity in
                    LocationViewCell(place: GooglePlaceDetails(from: placeEntity))
                        .onTapGesture {
                            onCitySelect?(GooglePlaceDetails(from: placeEntity))
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
