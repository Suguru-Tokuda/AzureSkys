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
    var coordinateSpaceName = WeatherViewIdentifiers.weatherScroll

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
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            navigationControls()
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
        .background {
            BackGroundView()
        }
    }
}

extension WeatherForecastView {
    @ViewBuilder func navigationControls() -> some View {
        Group {
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
            } else if presentation == .fullScreen {
                HStack {
                    DismissButton { coordinator.dismissForecast() }
                    Spacer()
                }
                .padding(20)
            } else if vm.locationAuthorized == true {
                HStack {
                    Spacer()
                    Button {
                        coordinator.goToLocations()
                    } label: {
                        Image(systemName: SystemImages.listBullet.rawValue)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 3, x: 0, y: 2)
                            .frame(width: 44, height: 44)
                            .modifier(WeatherPanelModifier(cornerRadius: 22))
                    }
                    .accessibilityLabel(Strings.locationsTitle.rawValue)
                    .accessibilityIdentifier(AccessibilityIdentifiers.locationsButton)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
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
        } else if vm.loadingStatus == .loading {
            ProgressView(Strings.loading.rawValue)
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
