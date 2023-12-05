//
//  WeatherDailyForecasetListView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherDailyForecasetListView: View {
    var list: [WeatherForecast]
    
    var body: some View {
        ForEach(list) { forecast in
            WeatherDailyForecasetListCellView(forecast: forecast)
        }
    }
}

#Preview {
    WeatherDailyForecasetListView(list: PreviewManager.weatherForecasetData.list)
}
