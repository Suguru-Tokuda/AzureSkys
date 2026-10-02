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
    var onCitySelect: ((GooglePlaceDetails?) -> Void)?
    
    init(dependencies: AppDependencies, onCitySelect: ((GooglePlaceDetails?) -> Void)? = nil) {
        self.dependencies = dependencies
        self.onCitySelect = onCitySelect
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
                        onCitySelect?(nil)
                    }
            }
            ForEach(results) { placeEntity in
                LocationViewCell(dependencies: dependencies, place: GooglePlaceDetails(from: placeEntity))
                    .onTapGesture {
                        onCitySelect?(GooglePlaceDetails(from: placeEntity))
                    }
            }
            .onDelete { indexSet in
                vm.removeCity(results: results, indexSet: indexSet)
            }
            .alert(isPresented: $vm.hasError, error: vm.coreDataError) {
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
