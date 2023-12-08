//
//  Int.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/7/23.
//

import Foundation

extension Int {
    func getTimeStr(dateFormat: String) -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .second, value: self, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        if let date {
            return dateFormatter.string(from: date)
        }
        
        return ""
    }
}
