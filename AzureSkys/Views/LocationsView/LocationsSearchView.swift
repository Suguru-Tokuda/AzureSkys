//
//  LocationsSearchView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 7/4/24.
//

import SwiftUI

struct LocationsSearchView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    let dependencies: AppDependencies
    @StateObject var vm: WeatherForecastViewModel
    @State var isActive: Bool?

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _vm = StateObject(wrappedValue: dependencies.makeWeatherForecastViewModel())
    }

    var body: some View {
        LocationsView(dependencies: dependencies, showDismiss: false) { place in
            coordinator.setPlaceWithFullScreen(place: place)
            vm.setPlace(place: place)
            vm.startDataRefreshTimer()
        }
        .fullScreenCover(isPresented: $coordinator.showWeatherForecastFullScreenSheet) {
            WeatherForecastScrollView(forecast: vm.forecast,
                                      geocode: vm.geocode,
                                      networkError: vm.networkError,
                                      loadingStatus: vm.loadingStatus,
                                      dismissible: true)
            .onDisappear {
                vm.endDataRefreshTimer()
            }
            .onReceive(NotificationCenter
                        .default
                        .publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                if isActive != nil {
                    self.isActive = true
                    vm.startDataRefreshTimer()
                }
            }
            .onReceive(NotificationCenter
                        .default
                        .publisher(for: UIApplication.willResignActiveNotification)) { _ in
                isActive = false
                vm.endDataRefreshTimer()
            }
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    LocationsSearchView(dependencies: dependencies)
        .appEnvironment(dependencies)
}
