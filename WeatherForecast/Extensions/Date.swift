//
//  Date.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/5/23.
//

import Foundation

extension Date {
    func getWeekDayStr() -> String {
        // comapre today and self first
        var dayComparison = Calendar.current.compare(Date(), to: self, toGranularity: .day)
        
        // if it's the same day then return "Today"
        if dayComparison == .orderedSame {
            return "Today"
        } else { // otherwise it returns a weekday string
            let weekday = Calendar.current.component(.weekday, from: self)
            return Weekdays.getWeekday(day: weekday).rawValue
        }
    }
}
