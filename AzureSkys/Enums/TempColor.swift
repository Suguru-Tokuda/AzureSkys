//
//  TempColor.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/15/23.
//

import SwiftUI

enum TempColor {
    case freezing,
        cold,
        cool,
        warm,
        hot

    static func getTempColor(tempInKelvin: Double) -> TempColor {
        if tempInKelvin > 273.15 + 37.8 {
            return .hot
        }

        if tempInKelvin >= 273.15 + 15.0 {
            return .warm
        }

        if tempInKelvin >= 273.15 + 10.0 {
            return .cool
        }

        if tempInKelvin >= 273.15 + 5 {
            return .cold
        }

        return .freezing
    }

    func getColor() -> Color {
        switch self {
        case .freezing:
            return Color.cold
        case .cold:
            return Color.cold
        case .cool:
            return Color.cool
        case .warm:
            return Color.warm
        case .hot:
            return Color.hot
        }
    }
}
