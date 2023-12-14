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
    let persistenceController = PersistenceController.shared
    
    init() {
        _locationManager = StateObject(wrappedValue: LocationManager())
        _mainCoordinator = StateObject(wrappedValue: MainCoordinator())
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = .clear
        
        UINavigationBar.appearance().barTintColor = .clear
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .white
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(mainCoordinator)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
