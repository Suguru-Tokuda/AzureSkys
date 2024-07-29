//
//  WeatherDailyForecastListCellView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherDailyForecastListCellView: View {
    @AppStorage(UserDefaultKeys.tempScale.rawValue) var tempScale: TempScale = .fahrenheit
    var forecast: DailyForecast
    var showTempBarAnimation: Bool = true
    
    var body: some View {
        ZStack {
            Color.clear
                .blur(radius: 3.0, opaque: false)
            HStack(alignment: .center, spacing: 20) {
                Text(forecast.dateTime.unixTimeToDateStr(dateFormat: Constants.dateFormat) .getDate(dateFormat: Constants.dateFormat).getWeekDayStr())
                    .frame(width: 50, alignment: .leading)
                if let weather = forecast.weather.first {
                    WeatherImageView(icon: weather.icon, width: 40)
                }
                Text("\(forecast.temp.min.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())")
                    .foregroundStyle(.white.opacity(0.5))
                TempBarView(currentTemp: 0, 
                            minTemp: forecast.temp.min,
                            maxTemp: forecast.temp.max,
                            height: 5,
                            showAnimation: showTempBarAnimation)
                    .padding(.top, 18)
                Text("\(forecast.temp.max.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())")
            }
            .padding(10)
            .fontWeight(.semibold)
        }
        .frame(height: 50)
    }
}

#Preview {
    WeatherDailyForecastListCellView(forecast: PreviewManager.oneCallResponse.daily.first!)
        .environmentObject(LocalFileManager())
        .preferredColorScheme(.dark)
}
