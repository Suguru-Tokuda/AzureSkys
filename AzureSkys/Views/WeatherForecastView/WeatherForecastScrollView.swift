//
//  AzureSkysFullView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 7/4/24.
//

import SwiftUI

struct WeatherForecastScrollView: View {
    var forecast: WeatherForecastOneCallResponse?
    var geocode: WeatherGeocode?
    var isMyLocation: Bool = true
    var showAnimation: Bool = true
    var onRefresh: (() -> ())?

    let coordinateSpaceName = "weatherScroll"
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if let geocode = geocode,
                   let forecast = forecast
                {
                    VStack {
                        WeatherForecastHeaderView(
                            geocode: geocode,
                            currentForecast: forecast.current,
                            dailyForecast: forecast.daily[0],
                            isMyLocation: isMyLocation,
                            scrollViewOffsetPercentage: .zero
                        )

                        WeatherThreeHourlyForecastListView(forecast: forecast)

                        WeatherDailyForecastListView(list: forecast.daily,
                                                     timezoneOffset: forecast.timezoneOffset,
                                                     showAnimation: self.showAnimation)

                        if let weather = forecast.current.weather.first {
                            StatusGridView(
                                forecast: forecast.current,
                                background: weather
                                                .weatherCondition
                                    .getBackgroundColor(partOfDay: weather.partOfDay,
                                                        clouds: forecast.current.clouds ?? 0),
                                parentViewWidth: geometry.size.width
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .scrollIndicators(.hidden)
        }
        .refreshable {
            onRefresh?()
        }
    }
}

#Preview {
    WeatherForecastScrollView(forecast: PreviewManager.oneCallResponse,
                            geocode: PreviewManager.geocode)
        .preferredColorScheme(.dark)
        .environmentObject(MainCoordinator())
}
