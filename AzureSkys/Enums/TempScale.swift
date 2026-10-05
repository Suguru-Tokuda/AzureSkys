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
        case .fahrenheit: return Strings.fahrenheit.rawValue
        case .celsius: return Strings.celsius.rawValue
        }
    }

    var shortName: String {
        switch self {
        case .fahrenheit: return Strings.fahrenheitSymbol.rawValue
        case .celsius: return Strings.celsiusSymbol.rawValue
        }
    }
}
