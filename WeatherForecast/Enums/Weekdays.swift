//
//  Weekdays.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/5/23.
//

import Foundation

enum Weekdays: String {
    case sunday = "Sun",
         monday = "Mon",
         tuesday = "Tue",
         wednesday = "Wed",
         thursday = "Thu",
         friday = "Fri",
         saturday = "Sat"
    
    static func getWeekday(day: Int) -> Weekdays {
        switch day {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return .sunday
        }
    }
}
