//
//  TempBarView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/15/23.
//

import SwiftUI

struct TempBarView: View {
    var currentTemp: Double
    var minTemp: Double
    var maxTemp: Double
    var showCurentTemp: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(.black.opacity(0.4))
                .frame(height: 7)
        }
        .padding()
    }
}

#Preview {
    TempBarView(currentTemp: 289.32, minTemp: 285.78, maxTemp: 292.26)
}
