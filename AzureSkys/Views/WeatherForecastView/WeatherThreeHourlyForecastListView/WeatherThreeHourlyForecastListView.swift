//
//  WeatherThreeHourlyForecastListView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/4/23.
//

import SwiftUI

struct WeatherThreeHourlyForecastListView: View {
    var forecast: WeatherForecastOneCallResponse
    
    @ScaledMetric(relativeTo: .body) private var hourlyCellHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.hourlyForecast.rawValue)
                .font(.headline)
                .foregroundStyle(.white)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(Array(forecast.hourly.enumerated()), id: \.offset) { i, item in
                        WeatherThreeHourlyForecastListViewCell(
                            forecast: item,
                            timezoneOffset: forecast.timezoneOffset,
                            isFirst: i == 0
                        )
                        .frame(width: 52, height: hourlyCellHeight)
                        .background {
                            if i == 0 {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.white.opacity(0.1))
                            }
                        }
                    }
                }
            }
            .frame(height: hourlyCellHeight)
            .scrollIndicators(.hidden)
        }
        .padding(14)
        .modifier(WeatherPanelModifier(cornerRadius: 25))
    }
}

#Preview {
    WeatherThreeHourlyForecastListView(forecast: PreviewManager.oneCallResponse)
        .preferredColorScheme(.dark)
}
