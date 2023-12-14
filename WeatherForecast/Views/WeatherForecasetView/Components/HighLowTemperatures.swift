//
//  HighLowTemperatures.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/7/23.
//

import SwiftUI

struct HighLowTemperatures: View {
    @AppStorage(AppStorageKeys.tempScale) var tempScale: TempScale = .fahrenheit
    var maxTemp: Double
    var minTemp: Double
    
    var body: some View {
        HStack {
            Text("H:\(maxTemp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())")
            Text("L:\(minTemp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())")
        }
    }
}

#Preview {
    HighLowTemperatures(maxTemp: 75, minTemp: 50)
}
