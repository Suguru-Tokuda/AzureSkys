//
//  HighLowTemperatures.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import SwiftUI

struct HighLowTemperatures: View {
    @AppStorage(UserDefaultKeys.tempScale.rawValue) var tempScale: TempScale = .fahrenheit
    var maxTemp: Double
    var minTemp: Double
    
    var body: some View {
        HStack {
            Text(WeatherFormatting.highTemperature(maxTemp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree()))
            Text(WeatherFormatting.lowTemperature(minTemp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree()))
        }
    }
}

#Preview {
    HighLowTemperatures(maxTemp: 75, minTemp: 50)
}
