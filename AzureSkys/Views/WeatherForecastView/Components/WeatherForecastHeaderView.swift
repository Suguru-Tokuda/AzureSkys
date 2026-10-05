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
        VStack(alignment: .center, spacing: -10) {
            Text(isMyLocation ? CommonStrings.myLocation : geocode.name)
                .font(.largeTitle)
            if isMyLocation {
                Text(geocode.name)
                    .font(.title3.weight(.semibold))
                    .padding(.top, 10)
            }
            Text(currentForecast.temp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())
                .font(.system(size: 96))
                .fontWeight(.thin)
                .offset(x: 10)
                .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
            
            VStack {
                if let weather = currentForecast.weather.first {
                    Text(weather.main)
                }
                
                HStack {
                    Spacer()
                    HighLowTemperatures(maxTemp: dailyForecast.temp.max, minTemp: dailyForecast.temp.min)
                    Spacer()
                }
            }
            .font(.title3.weight(.semibold))
        }
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
