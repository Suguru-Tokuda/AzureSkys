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
    @Environment(\.managedObjectContext) private var context
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _vm = StateObject(wrappedValue: dependencies.makeLocationsViewModel())
    }

    var body: some View {
        ZStack {
            if isSearching {
                BackGroundView()
                    .zIndex(2)
            }

            getLocationList()
        }
        .task(id: vm.refreshID(for: context)) {
            vm.observeChanges(in: context)
            await vm.loadPlaces()
        }
    }
}

extension LocationListView {
    @ViewBuilder
    private func getLocationList() -> some View {
        List {
            if let locationAuthorized = locationManager.locationAuthorized,
                locationAuthorized == true
            {
                LocationViewCell(dependencies: dependencies, isMyLocation: true)
                    .deleteDisabled(true)
                    .onTapGesture {
                        mainCoordinator.selectLocation(nil)
                    }
            }

            ForEach(vm.places) { place in
                LocationViewCell(dependencies: dependencies, place: place)
                    .onTapGesture {
                        mainCoordinator.selectLocation(place)
                    }
            }
            .onDelete { indexSet in
                Task {
                    await vm.removePlaces(at: indexSet)
                }
            }
            .alert(
                isPresented: Binding(
                    get: { vm.coreDataError != nil },
                    set: {
                        if !$0 {
                            vm.dismissError()
                        }
                    }
                ),
                error: vm.coreDataError
            ) {
                Button(
                    action: {
                        vm.dismissError()
                    },
                    label: {
                        Text(Strings.ok.rawValue)
                    }
                )
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
