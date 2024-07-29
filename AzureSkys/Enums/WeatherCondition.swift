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
    func getBackGroundColor(partOfDay: PartOfDay) -> LinearGradient {
        switch self {
        case .thunderstorm:
            switch partOfDay {
            case .night:
                return Color.cloudyNight
            case .day:
                return Color.cloudyDay
            }
        case .drizzel:
            switch partOfDay {
            case .night:
                return Color.cloudyNight
            case .day:
                return Color.cloudyDay
            }
        case .rain:
            switch partOfDay {
            case .night:
                return Color.cloudyNight
            case .day:
                return Color.cloudyDay
            }
        case .snow:
            switch partOfDay {
            case .night:
                return Color.cloudyNight
            case .day:
                return Color.cloudyDay
            }
        case .mist:
            switch partOfDay {
            case .night:
                return Color.cloudyNight
            case .day:
                return Color.cloudyDay
            }
        case .smoke:
            switch partOfDay {
            case .night:
                return Color.cloudyNight
            case .day:
                return Color.cloudyDay
            }
        case .haze:
            switch partOfDay {
            case .night:
                return Color.cloudyNight
            case .day:
                return Color.cloudyDay
            }
        case .dust:
            switch partOfDay {
            case .night:
                return Color.cloudyNight
            case .day:
                return Color.cloudyDay
            }
        case .fog:
            switch partOfDay {
            case .night:
                return Color.cloudyNight
            case .day:
                return Color.cloudyDay
            }
        case .sand:
            return Color.cloudyNight
        case .ash:
            return Color.cloudyNight
        case .squall:
            return Color.cloudyNight
        case .tornado:
            return Color.cloudyNight
        case .clear:
            switch partOfDay {
            case .night:
                return Color.clearNight
            case .day:
                return Color.skyBlue
            }
        case .clouds:
            switch partOfDay {
            case .night:
                return Color.cloudyNight
            case .day:
                return Color.cloudyDay
            }
        }
    }
}
