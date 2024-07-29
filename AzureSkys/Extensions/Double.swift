//
//  Preview.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

extension Double {
    func getDegree(tempScale: TempScale) -> Double {
        switch tempScale {
        case .fahrenheit:
            return kelvinToFahrenheight()
        case .celsius:
            return kelvinToCelsius()
        }
    }
    
    func kelvinToFahrenheight() -> Double {
        return (self - 273.15) * 9 / 5 + 32
    }
    
    func kelvinToCelsius() -> Double {
        return self - 273.10
    }
    
    func formatDouble(maxFractions: Int) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = maxFractions
        
        return formatter.string(from: self as NSNumber) ?? ""
    }
}
