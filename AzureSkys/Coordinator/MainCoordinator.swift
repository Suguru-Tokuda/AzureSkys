//
//  MainCoordinator.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

enum Route: Hashable {
    case settings
}

// Each destination carries the location it displays.
enum ForecastLocation: Identifiable {
    case current
    case saved(SavedPlace)

    var id: String {
        switch self {
        case .current: return MainCoordinatorConstants.current
        case .saved(let place): return MainCoordinatorConstants.savedLocationID(place.id)
        }
    }

    var place: SavedPlace? {
        if case .saved(let place) = self {
            return place
        }

        return nil
    }
}

enum FullScreenDestination: Identifiable {
    case locations
    case forecast(ForecastLocation)

    var id: String {
        switch self {
        case .locations: return MainCoordinatorConstants.locations
        case .forecast(let location): return MainCoordinatorConstants.forecastRouteID(location.id)
        }
    }
}

struct ForecastPreviewDestination: Identifiable {
    let id = UUID()
    let place: SavedPlace
}

@MainActor
final class MainCoordinator: ObservableObject {
    enum RootFlow {
        case onboarding
        case weather
    }

    @Published private(set) var selectedLocation: ForecastLocation = .current
    @Published var fullScreenDestination: FullScreenDestination?
    @Published var forecastPreview: ForecastPreviewDestination?
    @Published private(set) var rootFlow: RootFlow

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        rootFlow =
            defaults.bool(
                forKey: MainCoordinatorConstants.hasSeenOnboarding
            ) ? .weather : .onboarding
    }

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
        if case .locations = fullScreenDestination {
            fullScreenDestination = nil
        }
    }

    func dismissForecast() {
        if forecastPreview != nil {
            forecastPreview = nil
        } else if case .forecast = fullScreenDestination {
            fullScreenDestination = nil
        }
    }

    func completeOnboarding() {
        defaults.set(true, forKey: MainCoordinatorConstants.hasSeenOnboarding)
        rootFlow = .weather
    }
}

private enum MainCoordinatorConstants {
    static let current = "current"
    static let locations = "locations"
    static let hasSeenOnboarding = "hasSeenOnboarding"
    static func savedLocationID(_ placeID: String) -> String {
        "saved:\(placeID)"
    }

    static func forecastRouteID(_ locationID: String) -> String {
        "forecast:\(locationID)"
    }
}
