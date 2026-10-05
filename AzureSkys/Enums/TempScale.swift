//
//  TempScale.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/4/23.
//

import Foundation

enum TempScale: String, CaseIterable, Identifiable {
    // Preserve the stored value used by existing preferences and Settings.bundle.
    case fahrenheit = "Fahrenheight", celsius = "Celsius"
    
    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .fahrenheit: return TemperatureStrings.fahrenheit
        case .celsius: return TemperatureStrings.celsius
        }
    }

    var shortName: String {
        switch self {
        case .fahrenheit: return TemperatureStrings.fahrenheitSymbol
        case .celsius: return TemperatureStrings.celsiusSymbol
        }
    }
}
