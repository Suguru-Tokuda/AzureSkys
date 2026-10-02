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
        NavigationStack(path: $coordinator.path) {
            coordinator.getPage(page: .forecast, dependencies: dependencies)
                .navigationDestination(for: Page.self) { page in
                    coordinator.getPage(page: page, dependencies: dependencies)
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
