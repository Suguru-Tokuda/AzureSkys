//
//  WeatherForecastFullView.swift
//  WeatherForecast
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
                            
                            WeatherThreeHourlyForecastListView(forecasts: forecast.hourly)
                            
                            WeatherDailyForecastListView(list: forecast.daily)
                            
                            if let weather = forecast.current.weather.first {
                                StatusGridView(
                                    forecast: forecast.current,
                                    background: weather
                                                    .weatherCondition
                                                    .getBackGroundColor(partOfDay: weather.partOfDay),
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
