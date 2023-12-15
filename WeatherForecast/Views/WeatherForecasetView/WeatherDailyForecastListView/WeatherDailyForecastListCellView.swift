//
//  WeatherDailyForecastListCellView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherDailyForecastListCellView: View {
    var forecast: DailyForecast

    var body: some View {
        ZStack {
            Color.clear
                .blur(radius: 3.0, opaque: false)
            HStack(spacing: 20) {
                Text(forecast.dateTime.unixTimeToDateStr(dateFormat: Constants.dateFormat) .getDate(dateFormat: Constants.dateFormat).getWeekDayStr())
                    .foregroundStyle(.white)
                    .frame(width: 50, alignment: .leading)
                if let weather = forecast.weather.first {
                    WeatherImageView(icon: weather.icon, width: 40)
                }
                Text("\(forecast.temp.min.kelvinToFahrenheight().formatDouble(maxFractions: 0).appendDegree())")
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Text("\(forecast.temp.max.kelvinToFahrenheight().formatDouble(maxFractions: 0).appendDegree())")
                    .foregroundStyle(.white)
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
