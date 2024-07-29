//
//  WeatherThreeHourlyForecastListView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/4/23.
//

import SwiftUI

struct WeatherThreeHourlyForecastListView: View {
    var forecasts: [Forecast]
    
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
        .backgroundBlur(radius: 25, opaque: true)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

#Preview {
    WeatherThreeHourlyForecastListView(forecasts: PreviewManager.oneCallResponse.hourly)
        .preferredColorScheme(.dark)
}
