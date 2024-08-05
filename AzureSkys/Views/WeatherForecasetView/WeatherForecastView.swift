//
//  AzureSkysView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherForecastView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss: DismissAction
    @StateObject var vm: WeatherForecastViewModel = WeatherForecastViewModel()
    @State var scrollViewOffset: CGFloat = .zero
    @State var isActive: Bool?
    var place: GooglePlaceDetails?
    var showTopActionBar: Bool = false
    var onLocationAdded: (() -> ())?
    var coordinateSpaceName = "weatherScroll"

    init(place: GooglePlaceDetails? = nil, showTopActionBar: Bool = false, onLocationAdded: (() -> ())? = nil) {
        self.place = place
        self.showTopActionBar = showTopActionBar
        self.onLocationAdded = onLocationAdded
    }

    var body: some View {
        ZStack {
            vm.background.ignoresSafeArea(edges: .all)
            if let networkError = vm.networkError {
                RetryView(errorMessage: networkError.localizedDescription) {
                    vm.startDataRefreshTimer()
                }
            } else {
                forecastView()
                    .padding(.bottom, 30)
                footer()
            }
        }
        .onAppear {
            vm.setLocationManager(locationManager: locationManager)
        }
        .onDisappear {
            vm.endDataRefreshTimer()
        }
        .task {
            if place != nil {
                vm.setPlace(place: place)
                vm.startDataRefreshTimer()
            }
        }
        .alert(isPresented: $vm.isErrorOccured, error: vm.networkError, actions: {
            Button(action: {
                vm.dismissError(error: vm.coreDataError)
            }, label: {
                Text("OK")
            })
        })
        .alert(isPresented: $vm.isErrorOccured, error: vm.coreDataError) {
            Button(action: {
                vm.dismissError(error: vm.coreDataError)
            }, label: {
                Text("OK")
            })
        }
        .onReceive(NotificationCenter
                    .default
                    .publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if isActive != nil {
                self.isActive = true
                vm.startDataRefreshTimer(showLoading: false)
            }
        }
        .onReceive(NotificationCenter
                    .default
                    .publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        isActive = false
        }
    }
}

extension WeatherForecastView {
    @ViewBuilder func forecastView() -> some View {
        VStack {
            if showTopActionBar {
                WeatherForecastAddHeaderView(cancelBtnTapped: {
                    dismiss()
                },
                addBtnTapped: {
                    vm.addPlace(place: place) { result in
                        switch result {
                        case .success(let added):
                            if added == true {
                                dismiss()
                                onLocationAdded?()
                            }
                            break
                        case .failure(_):
                            break
                        }
                    }
                })
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            } else {
                Spacer()
            }
            Spacer()
        }
            .zIndex(2.0)

        if vm.loadingStatus == .loaded {
            WeatherForecastScrollView(forecast: vm.forecast,
                                      geocode: vm.geocode,
                                      networkError: vm.networkError,
                                      loadingStatus: vm.loadingStatus,
                                      showAnimation: vm.refreshCount < 1,
                                      onRefresh: {
                vm.startDataRefreshTimer()
            })
            .padding(.top, 20)
        } else if vm.loadingStatus == .loading {
            ProgressView("Loading...")
        }
    }

    @ViewBuilder func footer() -> some View {
        if let locationAuthorized = vm.locationAuthorized {
            if !showTopActionBar && locationAuthorized {
                // MARK: Tab Bar
                WeatherForecastBottomBar(background: vm.background) {
                    vm.endDataRefreshTimer()
                }
                    .fullScreenCover(
                        isPresented: $coordinator.showLocationsFullScreenSheet
                    ) {
                        LocationsView(showDismiss: false) { place in
                            coordinator.setPlace(place: place)
                            vm.setPlace(place: place)
                            vm.startDataRefreshTimer()
                        }
                    }
            }
        }
    }

    @ViewBuilder
    func getLocationsView(showDismiss: Bool = true) -> some View {
        LocationsView(showDismiss: showDismiss) { place in
            coordinator.setPlace(place: place)
            vm.setPlace(place: place)
            vm.startDataRefreshTimer()
        }
    }
}

#Preview {
    NavigationStack {
        WeatherForecastView()
    }
        .preferredColorScheme(.dark)
        .environmentObject(MainCoordinator())
        .environmentObject(LocationManager())
        .environmentObject(LocalFileManager())
}
