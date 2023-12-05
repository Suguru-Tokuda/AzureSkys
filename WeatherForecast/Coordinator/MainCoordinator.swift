//
//  MainCoordinator.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/5/23.
//

import Foundation
import SwiftUI

@MainActor
class MainCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func startCoordinator() {
        path.append(Page.forecast)
    }
    
    func goToLocations() {
        path.append(Page.locations)
    }
    
    @ViewBuilder
    func getPage(page: Page) -> some View {
        switch page {
        case .forecast:
            WeatherForecastView()
        case .locations:
            LocationsView()
        }
    }
}

enum Page: String, CaseIterable, Identifiable {
    case forecast, locations
    var id: String { self.rawValue }
}
