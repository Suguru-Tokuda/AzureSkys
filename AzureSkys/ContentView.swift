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
        switch coordinator.rootFlow {
        case .onboarding:
            OnboardingFlow(
                dependencies: dependencies,
                onFinished: coordinator.completeOnboarding
            )

        case .weather:
            mainView
        }

    }

    private var mainView: some View {
        WeatherForecastMainView(dependencies: dependencies)
            .fullScreenCover(item: $coordinator.fullScreenDestination) { destination in
                switch destination {
                case .locations:
                    LocationsFlow(dependencies: dependencies, showDismiss: true)

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
