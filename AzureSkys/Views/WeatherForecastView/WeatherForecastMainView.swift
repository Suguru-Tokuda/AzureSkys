//
//  AzureSkysMainView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 7/4/24.
//

import SwiftUI

struct WeatherForecastMainView: View {
    let dependencies: AppDependencies
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var coordinator: MainCoordinator

    var body: some View {
        if locationManager.locationAuthorized == true {
            WeatherForecastView(dependencies: dependencies, location: coordinator.selectedLocation)
        } else {
            LocationsFlow(dependencies: dependencies, showDismiss: false)
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    WeatherForecastMainView(dependencies: dependencies)
        .appEnvironment(dependencies)
}
