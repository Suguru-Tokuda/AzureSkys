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
        ForEach(list) { forecast in
            WeatherDailyForecastListCellView(forecast: forecast,
                                             timezoneOffset: timezoneOffset,
                                             showTempBarAnimation: showAnimation)
        }
        .backgroundBlur(radius: 25, opaque: true)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

#Preview {
    WeatherDailyForecastListView(list: PreviewManager.oneCallResponse.daily,
                                 timezoneOffset: 0)
        .preferredColorScheme(.dark)
}
