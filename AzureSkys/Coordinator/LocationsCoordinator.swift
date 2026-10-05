//
//  LocationsCoordinator.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import Foundation
import SwiftUI

@MainActor
final class LocationsCoordinator: ObservableObject {
    enum Route: Hashable {
        case settings
    }

    @Published var path: [Route] = []

    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func showSettings() {
        path.append(.settings)
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .settings:
            SettingsView(dependencies: dependencies)
        }
    }
}
