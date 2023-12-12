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
    var place: GooglePlaceDetails?
    
    func startCoordinator() {
        path.append(Page.forecast)
    }
    
    func goToLocations() {
        showLocationsFullScreenSheet = true
    }

    func showForecastSheet(place: GooglePlaceDetails) {
        self.place = place
        self.weatherForecastSheetPresented = true
    }
    
    func setPlace(place: GooglePlaceDetails?) {
        self.place = place
    }
        
    @ViewBuilder
    func getPage(page: Page) -> some View {
        switch page {
        case .forecast:
            WeatherForecastView(place: place)
        }
    }
}

enum Page: String, CaseIterable, Identifiable {
    case forecast
    var id: String { self.rawValue }
}
