//
//  ContentView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.getPage(page: .forecast)
                .navigationDestination(for: Page.self) { page in
                    coordinator.getPage(page: page)
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MainCoordinator())
        .environmentObject(LocationManager())
        .preferredColorScheme(.dark)
}
