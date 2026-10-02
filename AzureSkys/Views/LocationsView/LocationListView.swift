//
//  LocationListView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import SwiftUI
import CoreData

struct LocationListView: View {
    @EnvironmentObject var mainCoordinator: MainCoordinator
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.isSearching) private var isSearching
    let dependencies: AppDependencies
    @StateObject var vm: LocationsViewModel
    @FetchRequest(entity: PlaceEntity.entity(), sortDescriptors: [])
    var results: FetchedResults<PlaceEntity>
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _vm = StateObject(wrappedValue: dependencies.makeLocationsViewModel())
    }

    var body: some View {
        ZStack {
            if isSearching {
                Color
                    .black
                    .opacity(0.4)
                    .zIndex(2)
            }
            getLocationList()
        }
    }
}

extension LocationListView {
    @ViewBuilder
    private func getLocationList() -> some View {
        List {
            if let locationAuthorized = locationManager.locationAuthorized,
               locationAuthorized == true {
                LocationViewCell(dependencies: dependencies, isMyLocation: true)
                    .deleteDisabled(true)
                    .onTapGesture {
                        mainCoordinator.selectLocation(nil)
                    }
            }
            ForEach(results) { placeEntity in
                LocationViewCell(dependencies: dependencies, place: SavedPlace(from: placeEntity))
                    .onTapGesture {
                        if let place = SavedPlace(from: placeEntity) {
                            mainCoordinator.selectLocation(place)
                        }
                    }
            }
            .onDelete { indexSet in
                vm.removeCity(results: results, indexSet: indexSet)
            }
            .alert(isPresented: Binding(get: { vm.coreDataError != nil }, set: { if !$0 { vm.dismissError() } }), error: vm.coreDataError) {
                Button(action: {
                    vm.dismissError()
                }, label: {
                    Text("OK")
                })
            }
        }
        .listStyle(.plain)
        .zIndex(1)
        .scrollIndicators(.never)
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    LocationListView(dependencies: dependencies)
        .preferredColorScheme(.dark)
        .appEnvironment(dependencies)
}
