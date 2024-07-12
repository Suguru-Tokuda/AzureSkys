//
//  WeatherForecastMainView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 7/4/24.
//

import SwiftUI

struct WeatherForecastMainView: View {
    @EnvironmentObject var locationManager: LocationManager
    var place: GooglePlaceDetails?

    var body: some View {
        if let locationAuthorized = locationManager.locationAuthorized {
            if locationAuthorized {
                WeatherForecastView(place: place)
            } else {
                LocationsSearchView()
            }
        } else {
            LaunchView()
        }
    }
}

#Preview {
    WeatherForecastMainView()
}
