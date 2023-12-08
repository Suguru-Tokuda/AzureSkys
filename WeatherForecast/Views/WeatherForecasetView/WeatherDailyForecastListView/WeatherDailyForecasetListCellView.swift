//
//  WeatherDailyForecasetListCellView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherDailyForecasetListCellView: View {
    var forecast: WeatherForecast

    var body: some View {
        ZStack {
            Color.clear
                .blur(radius: 3.0, opaque: false)
            HStack(spacing: 20) {
                Text(forecast.dateForecasted.getDate(dateFormat: Constants.dateFormat).getWeekDayStr())
                    .foregroundStyle(.white)
                    .frame(width: 50, alignment: .leading)
                if let weather = forecast.weathers.first {
                    AsyncImage(url: URL(string: Constants.weatherIconURL.replacingOccurrences(of: "ICON_CODE", with: weather.icon))) { img in
                        img
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.yellow)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                }
                Text("\(forecast.main.tempMin.kelvinToFahrenheight().formatDouble(maxFractions: 0).appendDegree())")
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Text("\(forecast.main.tempMax.kelvinToFahrenheight().formatDouble(maxFractions: 0).appendDegree())")
                    .foregroundStyle(.white)
            }
            .padding(10)
            .fontWeight(.semibold)
        }
        .frame(height: 50)
    }
}

#Preview {
    WeatherDailyForecasetListCellView(forecast: PreviewManager.weatherForecasetData.list[0])
        .preferredColorScheme(.dark)
}
