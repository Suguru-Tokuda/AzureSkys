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
    case drizzle = "Drizzle"
    case rain = "Rain"
    case snow = "Snow"
    case mist = "Mist"
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
    
    /// Cloud coverage blends the clear and cloudy artwork for the time of day.
    /// Other night conditions use tinted daytime artwork.
    func getBackgroundImage(partOfDay: PartOfDay, clouds: Int = 0) -> some View {
        let cloudOpacity = Double(min(max(clouds, 0), 100)) / 100
        let isNight = partOfDay == .night

        return GeometryReader { geometry in
            ZStack {
                switch self {
                case .clear, .clouds:
                    backgroundLayer(
                        named: isNight
                            ? Strings.weatherBackgroundClearNight.rawValue
                            : Strings.weatherBackgroundClearDay.rawValue,
                        size: geometry.size
                    )
                    backgroundLayer(
                        named: isNight
                            ? Strings.weatherBackgroundCloudsNight.rawValue
                            : Strings.weatherBackgroundCloudsDay.rawValue,
                        size: geometry.size
                    )
                    .opacity(cloudOpacity)
                default:
                    backgroundLayer(named: backgroundImageName, size: geometry.size)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            .colorMultiply(
                isNight && self != .clear && self != .clouds
                    ? Color(red: 0.22, green: 0.30, blue: 0.48)
                    : .white
            )
        }
        .accessibilityHidden(true)
    }

    private func backgroundLayer(named name: String, size: CGSize) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
    }

    private var backgroundImageName: String {
        switch self {
        case .thunderstorm: return Strings.weatherBackgroundThunderstormDay.rawValue
        case .drizzle: return Strings.weatherBackgroundDrizzleDay.rawValue
        case .rain: return Strings.weatherBackgroundRainDay.rawValue
        case .snow: return Strings.weatherBackgroundSnowDay.rawValue
        case .mist: return Strings.weatherBackgroundMistDay.rawValue
        case .smoke: return Strings.weatherBackgroundSmokeDay.rawValue
        case .haze: return Strings.weatherBackgroundHazeDay.rawValue
        case .dust: return Strings.weatherBackgroundDustDay.rawValue
        case .fog: return Strings.weatherBackgroundFogDay.rawValue
        case .sand: return Strings.weatherBackgroundSandDay.rawValue
        case .ash: return Strings.weatherBackgroundAshDay.rawValue
        case .squall: return Strings.weatherBackgroundSquallDay.rawValue
        case .tornado: return Strings.weatherBackgroundTornadoDay.rawValue
        case .clear: return Strings.weatherBackgroundClearDay.rawValue
        case .clouds: return Strings.weatherBackgroundCloudsDay.rawValue
        }
    }

    /**
        Get Color or Gradient
     */
    func getBackgroundColor(partOfDay: PartOfDay, clouds: Int = 0) -> LinearGradient {
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
