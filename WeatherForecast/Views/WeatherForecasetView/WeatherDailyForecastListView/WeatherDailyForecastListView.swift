//
//  WeatherDailyForecastListView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherDailyForecastListView: View {
    var list: [DailyForecast]
    var showAnimation: Bool = true
    
    var body: some View {
        ForEach(list) { forecast in
            WeatherDailyForecastListCellView(forecast: forecast,
                                             showTempBarAnimation: showAnimation)
        }
        .backgroundBlur(radius: 25, opaque: true)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

#Preview {
    WeatherDailyForecastListView(list: PreviewManager.oneCallResponse.daily)
        .preferredColorScheme(.dark)
}
