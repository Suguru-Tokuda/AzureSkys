//
//  WeatherForecastView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherForecastView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @EnvironmentObject var mainCoordinator: MainCoordinator
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss: DismissAction
    @StateObject var vm: WeatherForecastViewModel = WeatherForecastViewModel()
    var placeDetails: GooglePlaceDetailsResult?
    var showTopActionBar: Bool = false
        
    init(placeDetails: GooglePlaceDetailsResult? = nil, showTopActionBar: Bool = false) {
        self.placeDetails = placeDetails
        self.showTopActionBar = showTopActionBar
    }
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            VStack {
                if showTopActionBar {
                    WeatherForecastAddHeaderView(cancelBtnTapped: {
                        dismiss()
                    },
                    addBtnTapped: {
                        print("add")
                    })
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                } else {
                    Spacer()
                }
                Spacer(
                )
            }
            .zIndex(2.0)
            if !vm.isLoading {
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
            } else {
                ProgressView("Loading...")
            }
        }
        .toolbar {
            if !showTopActionBar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button(action: {
                        mainCoordinator.goToLocations()
                    }, label: {
                        Image(systemName: "list.bullet")
                    })
                    .fullScreenCover(isPresented: $coordinator.showLocationsFullScreenSheet) {
                        LocationsView()
                    }
                }
            }
        }
        .onAppear {
            vm.setLocationManager(locationManager: locationManager)
            
            if let placeDetails {
                Task {
                    await vm.getWeatherForecasetData(place: placeDetails)
                }                
            }
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
