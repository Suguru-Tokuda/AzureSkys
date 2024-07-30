//
//  WeatherCondition.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/11/23.
//

import Foundation
import SwiftUI

enum WeatherCondition: String, CaseIterable {
    case thunderstorm = "Thunderstorm"
    case drizzel = "Drizzel"
    case rain = "Rain"
    case snow = "Snow"
    case mist = "MIst"
    case smoke = "Smoke"
    case haze = "Haze"
    case dust = "Dust"
    case fog = "Fog"
    case sand = "Sand"
    case ash = "Ash"
    case squall = "Squall"
    case tornado = "Tornado"
    case clear = "Clear"
    case clouds = "Clouds"
    
    static func getWeatherCondition(str: String) -> WeatherCondition {
        var retVal: WeatherCondition?
        
        WeatherCondition.allCases.forEach { condition in
            if condition.rawValue == str {
                retVal = condition
            }
        }
        
        return retVal ?? .clear
    }
    
    /**
        Get Color or Gradient
     */
    func getBackGroundColor(partOfDay: PartOfDay, clouds: Int = 0) -> LinearGradient {
        switch partOfDay {
        case .night:
            if clouds > 40 {
                return Color.cloudyNight
            } else {
                return Color.clearNight
            }
        case .day:
            if clouds > 40 {
                return Color.cloudyDay
            } else {
                return Color.skyBlue
            }
        }
    }
}
