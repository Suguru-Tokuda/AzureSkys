//
//  ContentView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

struct ContentView: View {
    let dependencies: AppDependencies
    @EnvironmentObject var coordinator: MainCoordinator
    
    var body: some View {
        WeatherForecastMainView(dependencies: dependencies)
            .fullScreenCover(item: $coordinator.fullScreenDestination) { destination in
                switch destination {
                case .locations:
                    LocationsView(dependencies: dependencies, showDismiss: true)
                case .forecast(let location):
                    WeatherForecastView(dependencies: dependencies, location: location, presentation: .fullScreen)
                }
            }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    ContentView(dependencies: dependencies)
        .appEnvironment(dependencies)
        .preferredColorScheme(.dark)
}
