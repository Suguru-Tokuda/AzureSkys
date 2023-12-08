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
    @Published var showLocationsFullScreenSheet: Bool = false
    @Published var weatherForecastSheetPresented: Bool = false
    var city: City?
    
    func startCoordinator() {
        path.append(Page.forecast)
    }
    
    func goToLocations() {
        showLocationsFullScreenSheet = true
    }

    func showForecastSheet(city: City) {
        self.city = city
        self.weatherForecastSheetPresented = true
    }
    
    func setCity(city: City?) {
        self.city = city
    }
        
    @ViewBuilder
    func getPage(page: Page) -> some View {
        switch page {
        case .forecast:
            WeatherForecastView(city: city)
        }
    }
}

enum Page: String, CaseIterable, Identifiable {
    case forecast
    var id: String { self.rawValue }
}
