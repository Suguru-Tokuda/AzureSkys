//
//  WeatherForecasetHeaderView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/27/23.
//

import SwiftUI

struct WeatherForecasetHeaderView: View {
    @AppStorage(AppStorageKeys.tempScale) var tempScale: TempScale = .fahrenheit
    var city: City
    var forecast: WeatherForecast
    
    var body: some View {
        VStack(alignment: .center) {
            Text(city.name)
                .font(.largeTitle)
            Text("\(forecast.main.temp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())")
                .font(.system(size: 60))
                .fontWeight(.regular)
            if let weather = forecast.weathers.first {
                Group {
                    Text(weather.main)
                        .font(.title3)
                    HStack {
                        Spacer()
                        HighLowTemperatures(maxTemp: forecast.main.tempMax, minTemp: forecast.main.tempMin)
                        Spacer()
                    }
                }.fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    WeatherForecasetHeaderView(
        city: PreviewManager.weatherForecasetData.city,
        forecast: PreviewManager.weatherForecasetData.list.first!
    )
}
