//
//  LocationsView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

struct LocationsView: View {
    @EnvironmentObject private var coordinator: MainCoordinator
    @EnvironmentObject private var locationManager: LocationManager
    let dependencies: AppDependencies
    @StateObject var vm: LocationForecastViewModel
    @Environment(\.dismissSearch) private var dismissSearch
    @AppStorage(UserDefaultKeys.tempScale.rawValue) private var tempScale: TempScale = .fahrenheit
    var showDismiss: Bool = true
    
    init(dependencies: AppDependencies, showDismiss: Bool = true) {
        self.dependencies = dependencies
        self.showDismiss = showDismiss
        _vm = StateObject(wrappedValue: dependencies.makeLocationSearchViewModel())
    }

    var body: some View {
        NavigationStack {
            VStack {
                if let error = vm.networkError {
                    RetryView(errorMessage: error.localizedDescription) {
                        Task {
                            if !vm.searchText.isEmpty {
                                await vm.getPredictions(searchText: vm.searchText)
                            }
                        }
                    }
                } else {
                    if vm.searchText.isEmpty {
                        locationList()
                    } else {
                        locationSearchResult()
                    }
                }
            }
            .alert(isPresented: Binding(get: { vm.detailsError != nil }, set: { if !$0 { vm.dismissError() } }), error: vm.detailsError, actions: {
                Button(action: {
                    vm.dismissError()
                }, label: {
                    Text("OK")
                })
            })
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    if showDismiss {
                        DismissButton {
                            coordinator.dismissLocations()
                        }
                    }
                    if let locationAuthorized = locationManager.locationAuthorized,
                       locationAuthorized == false {
                        Button(action: {
                            dependencies.settingsManager.navigateToSettings()
                        }, label: {
                            Image(systemName: "gear")
                        })
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        ForEach(TempScale.allCases) { scale in
                            Button(action: {
                                tempScale = scale
                            }, label: {
                                tempScaleOptionBtn(selected: tempScale, option: scale)
                            })
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Weather")
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .autocorrectionDisabled()
            .navigationBarBackButtonHidden(true)
        }
        .sheet(item: $coordinator.forecastPreview) { destination in
            WeatherForecastView(dependencies: dependencies, location: .saved(destination.place), presentation: .preview)
        }
        .onChange(of: coordinator.forecastPreview?.id) { previous, current in
            if previous != nil && current == nil {
                vm.searchText = ""
                dismissSearch()
            }
        }
    }
}

extension LocationsView {
    @ViewBuilder
    func locationSearchResult() -> some View {
        if vm.loadingStatus == .loading {
            VStack {
                ProgressView("Loading...")
            }
        } else {
            VStack {
                LocationSearchResultListView(predictions: vm.predictions) { prediction in
                    dismissSearch()
                    UIApplication.shared.hideKeyboard()

                    Task {
                        if let details = await vm.getPlaceDetails(placeId: prediction.placeId) {
                            self.coordinator.previewForecast(place: details)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func locationList() -> some View {
        LocationListView(dependencies: dependencies)
    }
}

extension LocationsView {
    @ViewBuilder
    func tempScaleOptionBtn(selected: TempScale, option: TempScale) -> some View {
        HStack {
            if selected != option {
                Spacer()
                    .frame(width: 10)
            } else {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            Text(option.displayName)
            Spacer()
            Text("°\(option.displayName.first?.uppercased() ?? "")")
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    LocationsView(dependencies: dependencies)
        .preferredColorScheme(.dark)
        .appEnvironment(dependencies)
}
