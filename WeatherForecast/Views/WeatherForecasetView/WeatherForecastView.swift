//
//  WeatherForecastView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherForecastView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss: DismissAction
    @StateObject var vm: WeatherForecastViewModel = WeatherForecastViewModel()
    var city: City?
    var showTopActionBar: Bool = false
    var onLocationAdded: (() -> ())?
        
    init(city: City? = nil, showTopActionBar: Bool = false, onLocationAdded: (() -> ())? = nil) {
        self.city = city
        self.showTopActionBar = showTopActionBar
        self.onLocationAdded = onLocationAdded
    }
    
    var body: some View {
        ZStack {
            if let forecast = vm.forecast?.current,
               let weather = forecast.weather.first {
                weather.weatherCondition.getBackGroundColor(partOfDay: weather.partOfDay)
                    .ignoresSafeArea()
            }
            VStack {
                if showTopActionBar {
                    WeatherForecastAddHeaderView(cancelBtnTapped: {
                        dismiss()
                    },
                    addBtnTapped: {
                        vm.addCity(city: city) { result in
                            switch result {
                            case .success(let added):
                                if added == true {
                                    dismiss()
                                    onLocationAdded?()
                                }
                                break
                            case .failure(_):
                                break
                            }
                        }
                    })
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                } else {
                    Spacer()
                }
                Spacer(
                )
            }
            .zIndex(2.0)
            if !vm.isLoading {
                ScrollView {
                    if let geocode = vm.geocode,
                       let forecast = vm.forecast
                    {
                        VStack {
                            WeatherForecastHeaderView(geocode: geocode, currentForecast: forecast.current,
                                dailyForecast: forecast.daily[0],
                                isMyLocation: coordinator.city == nil
                            )
                            WeatherThreeHourlyForecastListView(forecasts: forecast.hourly)
                            WeatherDailyForecastListView(list: forecast.daily)
                        }
                        .padding(.top, 50)
                        .padding(.horizontal, 20)
                    }
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .toolbar {
            if !showTopActionBar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button(action: {
                        coordinator.goToLocations()
                    }, label: {
                        Image(systemName: "list.bullet")
                    })
                    .fullScreenCover(
                        isPresented: $coordinator.showLocationsFullScreenSheet
                    ) {
                        LocationsView() { city in
                            coordinator.setCity(city: city)
                            Task {
                                if let city {
                                    await vm.getWeatherForecastData(city: city)
                                } else {
                                    await vm.getWeatherForecastData()
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            vm.setLocationManager(locationManager: locationManager)
        }
        .task {
            if let city {
                await vm.getWeatherForecastData(city: city)
            }
        }
        .refreshable {
            Task {
                if let city {
                    await vm.getWeatherForecastData(city: city)
                } else {
                    await vm.getWeatherForecastData()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeatherForecastView()
    }
        .preferredColorScheme(.dark)
        .environmentObject(MainCoordinator())
        .environmentObject(LocationManager())
}

//#Preview {
//    struct WeatherForecastPreview: View {
//        var previewDataManager = PreviewDataManager()
//        @State var data: WeatherForecastResponse?
//        @State var count: Int?
//        
//        var body: some View {
//            WeatherForecastView(count: count ?? 0)
//                .environmentObject(LocationManager())
//                .task {
//                    data = try? await previewDataManager.getData(resourceName: "previewWeatherData", format: "json", type: WeatherForecastResponse.self)
//                    
//                    let fiveDayForecasts = data?.getDailyForecast()
//                    
//                    print(fiveDayForecasts)
//                    count = fiveDayForecasts?.count ?? 0
//                }
//        }
//    }
//    
//    return WeatherForecastPreview()
//}
