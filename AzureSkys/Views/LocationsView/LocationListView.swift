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
    @State private var places: [SavedPlace] = []
    @State private var refreshRevision = 0

    private struct RefreshID: Equatable {
        let context: ObjectIdentifier
        let revision: Int
    }
    
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
        .task(id: RefreshID(context: ObjectIdentifier(context), revision: refreshRevision)) {
            do {
                // The store serializes this fetch with cloud-sync reconfiguration.
                let fetchedPlaces = try await dependencies.placeStore.getPlacesFromDatabase()
                try Task.checkCancellation()
                places = fetchedPlaces
            } catch is CancellationError {
                // A newer context or database change has scheduled another fetch.
            } catch {
                guard !Task.isCancelled else { return }
                vm.coreDataError = .fetch
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave).receive(on: DispatchQueue.main)) { notification in
            guard let savedContext = notification.object as? NSManagedObjectContext,
                  savedContext.persistentStoreCoordinator === context.persistentStoreCoordinator else { return }
            refreshRevision += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { notification in
            guard let changedContext = notification.object as? NSManagedObjectContext,
                  changedContext === context else { return }
            refreshRevision += 1
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
            ForEach(places) { place in
                LocationViewCell(dependencies: dependencies, place: place)
                    .onTapGesture {
                        mainCoordinator.selectLocation(place)
                    }
            }
            .onDelete { indexSet in
                let selectedPlaces = indexSet.compactMap { index in
                    places.indices.contains(index) ? places[index] : nil
                }
                Task { await vm.removePlaces(selectedPlaces) }
            }
            .alert(isPresented: Binding(get: { vm.coreDataError != nil }, set: { if !$0 { vm.dismissError() } }), error: vm.coreDataError) {
                Button(action: {
                    vm.dismissError()
                }, label: {
                    Text(Strings.ok.rawValue)
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
