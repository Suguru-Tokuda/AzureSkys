//
//  MainCoordinator.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

// Each destination carries the location it displays.
enum ForecastLocation: Identifiable {
    case current
    case saved(SavedPlace)

    var id: String {
        switch self {
        case .current: return "current"
        case .saved(let place): return "saved:\(place.id)"
        }
    }

    var place: SavedPlace? {
        if case .saved(let place) = self { return place }
        return nil
    }
}

enum FullScreenDestination: Identifiable {
    case locations
    case forecast(ForecastLocation)

    var id: String {
        switch self {
        case .locations: return "locations"
        case .forecast(let location): return "forecast:\(location.id)"
        }
    }
}

struct ForecastPreviewDestination: Identifiable {
    let id = UUID()
    let place: SavedPlace
}

@MainActor
final class MainCoordinator: ObservableObject {
    @Published private(set) var selectedLocation: ForecastLocation = .current
    @Published var fullScreenDestination: FullScreenDestination?
    @Published var forecastPreview: ForecastPreviewDestination?

    func goToLocations() {
        fullScreenDestination = .locations
    }

    func selectLocation(_ place: SavedPlace?) {
        let location = place.map(ForecastLocation.saved) ?? .current
        if case .locations = fullScreenDestination {
            selectedLocation = location
            fullScreenDestination = nil
        } else {
            fullScreenDestination = .forecast(location)
        }
    }

    func previewForecast(place: SavedPlace) {
        forecastPreview = ForecastPreviewDestination(place: place)
    }

    func dismissLocations() {
        if case .locations = fullScreenDestination { fullScreenDestination = nil }
    }

    func dismissForecast() {
        if forecastPreview != nil {
            forecastPreview = nil
        } else if case .forecast = fullScreenDestination {
            fullScreenDestination = nil
        }
    }
}
