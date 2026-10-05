//
//  AzureSkysView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct WeatherForecastView: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @EnvironmentObject var locationManager: LocationManager
    let dependencies: AppDependencies
    @StateObject var vm: WeatherForecastViewModel
    @State var scrollViewOffset: CGFloat = .zero
    @State var isActive: Bool?
    let location: ForecastLocation
    let presentation: Presentation
    private var place: SavedPlace? { location.place }

    enum Presentation { case main, preview, fullScreen }
    var coordinateSpaceName = Strings.weatherScroll.rawValue

    init(dependencies: AppDependencies, location: ForecastLocation = .current, presentation: Presentation = .main) {
        self.dependencies = dependencies
        self.location = location
        self.presentation = presentation
        _vm = StateObject(wrappedValue: dependencies.makeWeatherForecastViewModel())
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if let forecast = vm.forecast,
                   let weather = forecast.current.weather.first {
                    weather.weatherCondition.getBackgroundImage(
                        partOfDay: weather.partOfDay,
                        clouds: forecast.current.clouds ?? 0
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                }
            }
            .ignoresSafeArea()
            if let networkError = vm.networkError {
                RetryView(errorMessage: networkError.localizedDescription) {
                    vm.startDataRefreshTimer()
                }
            } else {
                forecastView()
                    .padding(.bottom, 30)
            }
            navigationControls()
            footer()
        }
        .onAppear {
            vm.setLocationManager(locationManager: locationManager)
        }
        .onDisappear {
            vm.endDataRefreshTimer()
        }
        .task(id: location.id) {
            vm.setPlace(place: place)
            vm.startDataRefreshTimer()
        }
        .alert(isPresented: Binding(get: { vm.coreDataError != nil }, set: { if !$0 { vm.dismissError() } }), error: vm.coreDataError) {
            Button(action: {
                vm.dismissError()
            }, label: {
                Text(Strings.ok.rawValue)
            })
        }
        .onReceive(NotificationCenter
                    .default
                    .publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if isActive != nil {
                self.isActive = true
                vm.startDataRefreshTimer(showLoading: false)
            }
        }
        .onReceive(NotificationCenter
                    .default
                    .publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isActive = false
            vm.endDataRefreshTimer()
        }
    }
}

extension WeatherForecastView {
    @ViewBuilder func navigationControls() -> some View {
        VStack {
            if presentation == .preview {
                WeatherForecastAddHeaderView(cancelBtnTapped: {
                    coordinator.dismissForecast()
                },
                addBtnTapped: {
                    vm.addPlace(place: place) { result in
                        switch result {
                        case .success(let added):
                            if added == true {
                                coordinator.dismissForecast()
                            }
                            break
                        case .failure(_):
                            break
                        }
                    }
                })
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            } else if presentation == .fullScreen {
                HStack {
                    DismissButton { coordinator.dismissForecast() }
                    Spacer()
                }
                .padding(20)
            } else {
                Spacer()
            }
            Spacer()
        }
            .zIndex(2.0)
    }

    @ViewBuilder func forecastView() -> some View {
        if vm.loadingStatus == .loaded {
            WeatherForecastScrollView(forecast: vm.forecast,
                                      geocode: vm.geocode,
                                      isMyLocation: place == nil,
                                      showAnimation: vm.showForecastAnimation,
                                      onRefresh: {
                vm.startDataRefreshTimer()
            })
            .padding(.top, 20)
        } else if vm.loadingStatus == .loading {
            ProgressView(Strings.loading.rawValue)
        }
    }

    @ViewBuilder func footer() -> some View {
        if presentation == .main, vm.locationAuthorized == true {
            WeatherForecastBottomBar()
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    NavigationStack {
        WeatherForecastView(dependencies: dependencies)
    }
    .preferredColorScheme(.dark)
    .appEnvironment(dependencies)
}
