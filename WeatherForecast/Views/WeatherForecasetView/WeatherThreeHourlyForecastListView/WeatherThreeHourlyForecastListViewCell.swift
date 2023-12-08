//
//  WeatherThreeHourlyForecastListViewCell.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/4/23.
//

import SwiftUI

struct WeatherThreeHourlyForecastListViewCell: View {
    @AppStorage(AppStorageKeys.tempScale) var tempScale: TempScale = .fahrenheit
    var forecast: WeatherForecast
    var isFirst: Bool
    
    var body: some View {
        VStack {
            Text(isFirst ? "Now" : forecast.dateForecasted.getDateStrinng(dateFormat: Constants.dateFormat, newDateFormat: "ha"))
            if let weather = forecast.weathers.first {
                AsyncImage(url: URL(string: Constants.weatherIconURL.replacingOccurrences(of: "ICON_CODE", with: weather.icon))) { img in
                    img
                        .resizable()
                        .frame(width: 40, height: 40)
                } placeholder: {
                    ProgressView()
                        .frame(width: 40, height: 40)
                }
            }
            Text("\(forecast.main.temp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())")
        }
        .fontWeight(.bold)
    }
}

#Preview {
    WeatherThreeHourlyForecastListViewCell(forecast: PreviewManager.weatherForecasetData.list[0],
                                           isFirst: false
    )
        .preferredColorScheme(.dark)
}
