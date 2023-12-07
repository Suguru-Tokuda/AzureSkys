//
//  LocationsView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

struct LocationsView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @StateObject var vm: LocationForecasetViewModel = LocationForecasetViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.isSearching) var isSearching: Bool
    @Environment(\.dismissSearch) var dismissSearch
    @AppStorage(AppStorageKeys.tempScale) var tempScale: TempScale = .fahrenheit
    
    var body: some View {
        NavigationStack {
            VStack {
                if vm.searchText.isEmpty {
                    locationList()
                } else {
                    locationSearchResult()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 15, height: 15)
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
            WeatherForecastView(placeDetails: coordinator.placeDetails, showTopActionBar: true)
        }
    }
}

extension LocationsView {
    @ViewBuilder
    func locationSearchResult() -> some View {
        if vm.isLoading {
            VStack {
                ProgressView("Loading...")
            }
        } else {
            VStack {
                LocationSearchResultListView(predictions: vm.predictions) { prediction in
                    Task {
                        if let details = await vm.getPlaceDetails(placeId: prediction.placeId) {
                            self.coordinator.showForecastSheet(location: details)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func locationList() -> some View {
        Text("")
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
}
