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
    var place: GooglePlaceDetails?

    var body: some View {
        if let locationAuthorized = locationManager.locationAuthorized {
            if locationAuthorized {
                WeatherForecastView(dependencies: dependencies, place: place)
            } else {
                LocationsSearchView(dependencies: dependencies)
            }
        } else {
            LaunchView()
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    WeatherForecastMainView(dependencies: dependencies)
        .appEnvironment(dependencies)
}
