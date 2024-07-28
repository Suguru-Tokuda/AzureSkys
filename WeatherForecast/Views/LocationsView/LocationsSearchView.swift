//
//  LocationsSearchView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 7/4/24.
//

import SwiftUI

struct LocationsSearchView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @StateObject var vm: WeatherForecastViewModel = WeatherForecastViewModel()

    var body: some View {
        LocationsView(showDismiss: false) { place in
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
        }
    }
}

#Preview {
    LocationsSearchView()
}
