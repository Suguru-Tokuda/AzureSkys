//
//  LocationsView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

struct LocationsView: View {
    @EnvironmentObject private var coordinator: MainCoordinator
    @EnvironmentObject private var locationManager: LocationManager
    @StateObject var vm: LocationForecastViewModel = LocationForecastViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissSearch) private var dismissSearch
    @AppStorage(UserDefaultKeys.tempScale.rawValue) private var tempScale: TempScale = .fahrenheit
    @State var searchBarPresented = false
    private let settingsManager = SettingsManager()
    var showDismiss: Bool = true
    var onDismiss: ((GooglePlaceDetails?) -> Void)?
    
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
            .alert(isPresented: $vm.isErrorOccured, error: vm.networkError, actions: {
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
                            dismiss()
                        }
                    }
                    if let locationAuthorized = locationManager.locationAuthorized,
                       locationAuthorized == false {
                        Button(action: {
                            settingsManager.navigateToSettings()
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
            .navigationBarBackButtonHidden(true)
        }
        .sheet(isPresented: $coordinator.weatherForecastSheetPresented) {
            WeatherForecastView(
                place: coordinator.place,
                showTopActionBar: true) {
                    DispatchQueue.main.async {
                        self.vm.searchText = ""
                        self.dismissSearch()
                    }
                }
        }
    }
}

extension LocationsView {
    @ViewBuilder
    func locationSearchResult() -> some View {
        if vm.isLoading == .loading {
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
                            self.coordinator.showForecastSheet(place: details)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func locationList() -> some View {
        LocationListView() { place in
            if let onDismiss {
                onDismiss(place)
                dismiss()
            }
        }
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
            Text(option.rawValue)
            Spacer()
            Text("&deg;\(option.rawValue.first?.uppercased() ?? "")")
        }
    }
}

#Preview {
    LocationsView()
        .preferredColorScheme(.dark)
        .environmentObject(LocationManager())
        .environmentObject(MainCoordinator())
        .environmentObject(LocalFileManager())
}
