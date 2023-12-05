//
//  WeatherForecastView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherForecastView: View {
    @EnvironmentObject var mainCoordinator: MainCoordinator
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var vm: WeatherForecastViewModel = WeatherForecastViewModel()
    var showTopActionBar: Bool = false
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            VStack {
                if showTopActionBar {
                    WeatherForecastAddHeaderView(cancelBtnTapped: {
                        print("cancel")
                    },
                    addBtnTapped: {
                        print("add")
                    })
                    .padding(.horizontal, 20)
                } else {
                    Spacer()
                }
                Spacer(
                )
            }
            .zIndex(2.0)
            ScrollView {
                if let city = vm.city,
                   let firstForecast = vm.fiveDayForecast.first
                {
                    VStack {
                        WeatherForecasetHeaderView(city: city, forecast: firstForecast)
                        WeatherThreeHourlyForecastListView(forecasts: vm.weatherList)
                        WeatherDailyForecasetListView(list: vm.fiveDayForecast)
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 20)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button(action: {
                    mainCoordinator.goToLocations()
                }, label: {
                    Image(systemName: "list.bullet")
                })
            }
        }
        .onAppear {
            vm.setLocationManager(locationManager: locationManager)
        }
    }
}

#Preview {
    NavigationStack {
        WeatherForecastView()
    }
        .environmentObject(LocationManager())
}

//#Preview {
//    struct WeatherForecasetPreview: View {
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
//    return WeatherForecasetPreview()
//}
