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
            switch clouds {
            case 91...100:
                return Color.cloudyNight100
            case 81...90:
                return Color.cloudyNight90
            case 71...80:
                return Color.cloudyNight80
            case 61...70:
                return Color.cloudyNight70
            case 51...60:
                return Color.cloudyNight60
            case 41...50:
                return Color.cloudyNight50
            case 31...40:
                return Color.clearNight70
            case 21...30:
                return Color.clearNight80
            case 11...20:
                return Color.clearNight90
            case 0...10:
                return Color.clearNight100
            default:
                return Color.clearNight100
            }
        case .day:
            switch clouds {
            case 91...100:
                return Color.cloudyDay100
            case 81...90:
                return Color.cloudyDay90
            case 71...80:
                return Color.cloudyDay80
            case 61...70:
                return Color.cloudyDay70
            case 51...60:
                return Color.cloudyDay60
            case 41...50:
                return Color.cloudyDay50
            case 31...40:
                return Color.skyBlue70
            case 21...30:
                return Color.skyBlue80
            case 11...20:
                return Color.skyBlue90
            case 0...10:
                return Color.skyBlue100
            default:
                return Color.skyBlue100
            }
        }
    }
}
