//
//  Int.swift
//  AzureSkys
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
    
    func unixTimeToDateStr(dateFormat: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
            
        return dateFormatter.string(from: date)
    }
    
    func toMiles() -> Int {
        return Int(Double(self) / 1609.44)
    }
}
