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
    var place: GooglePlaceDetails?
    var showTopActionBar: Bool = false
    var onLocationAdded: (() -> ())?
        
    init(place: GooglePlaceDetails? = nil, showTopActionBar: Bool = false, onLocationAdded: (() -> ())? = nil) {
        self.place = place
        self.showTopActionBar = showTopActionBar
        self.onLocationAdded = onLocationAdded
    }
    
    var body: some View {
        ZStack {
            vm.background.ignoresSafeArea(edges: .all)
            
            if vm.locationAuthorized {
                locationAuthorizedView()
            } else {
                LocationAuthorizationRequestView()
            }
            
            footer()
        }
        .onAppear {
            vm.setLocationManager(locationManager: locationManager)
        }
        .task {
            if let place,
               vm.locationAuthorized {
                await vm.getWeatherForecastData(place: place)
            }
        }
    }
}

extension WeatherForecastView {
    @ViewBuilder func locationAuthorizedView() -> some View {
        VStack {
            if showTopActionBar {
                WeatherForecastAddHeaderView(cancelBtnTapped: {
                    dismiss()
                },
                addBtnTapped: {
                    vm.addPlace(place: place) { result in
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
            Spacer()
        }
            .zIndex(2.0)
        
        if !vm.isLoading {
            GeometryReader { reader in
                ScrollView {
                    if let geocode = vm.geocode,
                       let forecast = vm.forecast
                    {
                        mainView(forecast: forecast, geocode: geocode, parentViewWidth: reader.size.width)
                        .padding(.top, 50)
                        .padding(.bottom, 50)
                        .padding(.horizontal, 20)
                    }
                }
            }
            .refreshable {
                Task {
                    if let place {
                        await vm.getWeatherForecastData(place: place)
                    } else {
                        await vm.getWeatherForecastData()
                    }
                }
            }
        } else {
            ProgressView("Loading...")
        }
    }
    
    @ViewBuilder func mainView(forecast: WeatherForecastOneCallResponse, geocode: WeatherGeocode, parentViewWidth: CGFloat) -> some View {
        VStack {
            WeatherForecastHeaderView(geocode: geocode, currentForecast: forecast.current,
                dailyForecast: forecast.daily[0],
                isMyLocation: coordinator.place == nil
            )
            WeatherThreeHourlyForecastListView(forecasts: forecast.hourly)
            WeatherDailyForecastListView(list: forecast.daily)
            if let weather = forecast.current.weather.first {
                StatusGridView(
                    forecast: forecast.current,
                    background: weather.weatherCondition.getBackGroundColor(partOfDay: weather.partOfDay),
                    parentViewWidth: parentViewWidth
                )
            }
        }
    }
    
    @ViewBuilder func footer() -> some View {
        if !showTopActionBar && vm.locationAuthorized {
            // MARK: Tab Bar
            WeatherForecastBottomBar(background: vm.background)
                .fullScreenCover(
                    isPresented: $coordinator.showLocationsFullScreenSheet
                ) {
                    LocationsView() { place in
                        coordinator.setPlace(place: place)
                        Task {
                            if let place {
                                await vm.getWeatherForecastData(place: place)
                            } else {
                                await vm.getWeatherForecastData()
                            }
                        }
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
