//
//  WeatherForecastApp.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/27/23.
//

import SwiftUI

@main
struct WeatherForecastApp: App {
    @StateObject var locationManager: LocationManager
    @StateObject var mainCoordinator: MainCoordinator
    
    init() {
        _locationManager = StateObject(wrappedValue: LocationManager())
        _mainCoordinator = StateObject(wrappedValue: MainCoordinator())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(mainCoordinator)
        }
    }
}
