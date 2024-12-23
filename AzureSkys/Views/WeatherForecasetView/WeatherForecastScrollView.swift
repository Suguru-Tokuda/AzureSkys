//
//  AzureSkysFullView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 7/4/24.
//

import SwiftUI

struct WeatherForecastScrollView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coordinator: MainCoordinator
    var forecast: WeatherForecastOneCallResponse?
    var geocode: WeatherGeocode?
    var networkError: NetworkError?
    var loadingStatus: LoadingStatus?
    var showAnimation: Bool = true
    var onRefresh: (() -> ())?
    var onRetryBtnTapped: (() -> ())?
    
    let coordinateSpaceName = "weatherScroll"
    var dismissible: Bool = false
    
    var body: some View {
        if networkError != nil {
            RetryView(errorMessage: networkError!.localizedDescription) {
                onRetryBtnTapped?()
            }
        } else if loadingStatus == .loaded && networkError == nil {
            GeometryReader { geometry in
                ScrollView {
                    if let geocode = geocode,
                       let forecast = forecast
                    {
                        VStack {
                            if dismissible {
                                HStack {
                                    DismissButton {
                                        dismiss()
                                    }
                                    Spacer()
                                }
                            }
                            WeatherForecastHeaderView(
                                geocode: geocode,
                                currentForecast: forecast.current,
                                dailyForecast: forecast.daily[0],
                                isMyLocation: coordinator.place == nil,
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
                                        .getBackGroundColor(partOfDay: weather.partOfDay,
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
        } else if loadingStatus == .loading {
            ProgressView("Loading...")
        }
    }
}

#Preview {
    WeatherForecastScrollView(forecast: PreviewManager.oneCallResponse, 
                            geocode: PreviewManager.geocode)
        .preferredColorScheme(.dark)
        .environmentObject(MainCoordinator())
}
