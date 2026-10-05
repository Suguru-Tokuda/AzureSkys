//
//  LocationsFlow.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import SwiftUI

struct LocationsFlow: View {
    let dependencies: AppDependencies
    var showDismiss: Bool = true

    @StateObject private var coordinator: LocationsCoordinator

    init(dependencies: AppDependencies, showDismiss: Bool) {
        self.dependencies = dependencies
        self.showDismiss = showDismiss
        self._coordinator = StateObject(wrappedValue: LocationsCoordinator(dependencies: dependencies))
    }

    var body: some View {
        LocationsView(
            dependencies: dependencies,
            showDismiss: showDismiss
        )
        .environmentObject(coordinator)
    }
}
