//
//  WeatherForecastHeaderView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/27/23.
//

import SwiftUI

struct WeatherForecastHeaderView: View {
    @AppStorage(AppStorageKeys.tempScale) var tempScale: TempScale = .fahrenheit
    var geocode: WeatherGeocode
    var currentForecast: Forecast
    var dailyForecast: DailyForecast
    var isMyLocation: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: -10) {
            Text(isMyLocation ? "My Location" : geocode.name)
                .font(.largeTitle)
            if isMyLocation {
                Text(geocode.name)
                    .font(.title3.weight(.semibold))
                    .padding(.top, 10)
            }
            Text("\(currentForecast.temp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())")
                .font(.system(size: 96))
                .fontWeight(.thin)
                .offset(x: 10)
            
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
    }
}

#Preview {
    WeatherForecastHeaderView(
        geocode: PreviewManager.geocode,
        currentForecast: PreviewManager.oneCallResponse.current,
        dailyForecast: PreviewManager.oneCallResponse.daily.first!
    )
    .preferredColorScheme(.dark)
}
