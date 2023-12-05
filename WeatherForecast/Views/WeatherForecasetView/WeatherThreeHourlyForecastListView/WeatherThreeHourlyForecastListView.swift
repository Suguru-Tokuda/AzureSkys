//
//  WeatherThreeHourlyForecastListView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/4/23.
//

import SwiftUI

struct WeatherThreeHourlyForecastListView: View {
    var forecasts: [WeatherForecast]
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 20) {
                ForEach(Array(forecasts.enumerated()), id: \.offset) { i, item in
                    WeatherThreeHourlyForecastListViewCell(forecast: item, isFirst: i == 0)
                        .frame(minHeight: 150)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    WeatherThreeHourlyForecastListView(forecasts: PreviewManager.weatherForecasetData.list)
}
