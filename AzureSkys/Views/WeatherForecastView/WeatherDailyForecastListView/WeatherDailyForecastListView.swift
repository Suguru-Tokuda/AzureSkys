//
//  WeatherDailyForecastListView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherDailyForecastListView: View {
    var list: [DailyForecast]
    var timezoneOffset: Int
    var showAnimation: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.dailyForecast.rawValue)
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 0) {
                ForEach(list) { forecast in
                    WeatherDailyForecastListCellView(forecast: forecast,
                                                     timezoneOffset: timezoneOffset,
                                                     showTempBarAnimation: showAnimation)
                }
            }
        }
        .padding(14)
        .modifier(WeatherPanelModifier(cornerRadius: 25))
    }
}

#Preview {
    WeatherDailyForecastListView(list: PreviewManager.oneCallResponse.daily,
                                 timezoneOffset: 0)
        .preferredColorScheme(.dark)
}
