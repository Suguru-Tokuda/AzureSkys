//
//  String.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/4/23.
//

import Foundation

extension String {
    // Return a date object for string.
    // If the converted date is nil, then it returns a new Date as of today
    func getDate(dateFormat: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.date(from: self) ?? Date()
    }
    
    func getDateStrinng(dateFormat: String, newDateFormat: String) -> String {
        let date = self.getDate(dateFormat: dateFormat)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = newDateFormat
        
        return dateFormatter.string(from: date)
    }
    
    func appendDegree() -> String {
        return "\(self)\u{00B0}"
    }
}
