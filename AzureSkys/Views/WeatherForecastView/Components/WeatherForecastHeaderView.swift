//
//  AzureSkysHeaderView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//

import SwiftUI

struct WeatherForecastHeaderView: View {
    @AppStorage(UserDefaultKeys.tempScale.rawValue) var tempScale: TempScale = .fahrenheit
    var geocode: WeatherGeocode
    var currentForecast: Forecast
    var dailyForecast: DailyForecast
    var isMyLocation: Bool = false
    var scrollViewOffsetPercentage: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: -10) {
            HStack(alignment: .top) {
                Image(systemName: SystemImages.mapPin.rawValue)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .modifier(WeatherPanelModifier(cornerRadius: 22))
                VStack(alignment: .leading, spacing: 0) {
                    Text(isMyLocation ? Strings.myLocation.rawValue : geocode.name)
                        .font(.largeTitle)
                    if isMyLocation {
                        Text(geocode.name)
                            .font(.title3.weight(.semibold))
                            .padding(.top, 10)
                    }
                }
                .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
            }

            Text(currentForecast.temp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())
                .font(.system(size: 96))
                .fontWeight(.thin)
                .offset(x: 10)
                .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading) {
                if let weather = currentForecast.weather.first {
                    Text(weather.main)
                }

                HighLowTemperatures(maxTemp: dailyForecast.temp.max, minTemp: dailyForecast.temp.min)
            }
            .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .shadow(
            color: .black.opacity(0.5),
            radius: 3,
            x: 0,
            y: 2
        )
    }
}

#Preview {
    WeatherForecastHeaderView(
        geocode: PreviewManager.geocode,
        currentForecast: PreviewManager.oneCallResponse.current,
        dailyForecast: PreviewManager.oneCallResponse.daily.first!,
        scrollViewOffsetPercentage: .zero
    )
    .preferredColorScheme(.dark)
}
