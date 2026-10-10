//
//  LocationViewCell.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

struct LocationViewCell: View {
    @AppStorage(UserDefaultKeys.tempScale.rawValue) var tempScale: TempScale = .fahrenheit
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var vm: CurrentWeatherForecastViewModel
    var place: SavedPlace?
    var isMyLocation: Bool = false

    init(dependencies: AppDependencies, place: SavedPlace? = nil, isMyLocation: Bool = false) {
        _vm = StateObject(wrappedValue: dependencies.makeCurrentWeatherViewModel())
        self.isMyLocation = isMyLocation
        self.place = place
    }

    var body: some View {
        ZStack {
            if vm.loadingStatus == .loading {
                ProgressView(Strings.loading.rawValue)
            }

            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        // MARK: Location Text
                        Text(isMyLocation ? Strings.myLocation.rawValue : place?.name ?? "")
                            .font(.title3)
                            .fontWeight(.bold)
                        // MARK: Time
                        Text(
                            isMyLocation
                                ? vm.currentForecast?.name ?? ""
                                : vm.currentForecast?
                                    .dateTime
                                    .unixTimeToDateStr(
                                        dateFormat: Constants.dateFormat,
                                        timezoneOffset: vm.currentForecast?.timezone ?? 0
                                    )
                                    .getDateStrinng(
                                        dateFormat: Constants.dateFormat,
                                        newDateFormat: "hh:mm"
                                    ) ?? ""
                        )
                        .font(.caption)
                        .fontWeight(.semibold)
                    }

                    Spacer()

                    if let currentForecast = vm.currentForecast {
                        // MARK: Degree
                        Text(
                            currentForecast
                                .main
                                .temp
                                .getDegree(tempScale: tempScale)
                                .formatDouble(maxFractions: 0)
                                .appendDegree()
                        )
                        .font(.largeTitle)
                    }
                }

                Spacer()
                    .frame(height: 25)
                HStack {
                    HStack {
                        Text(vm.currentForecast?.weather.first?.main ?? Strings.unavailable.rawValue)

                        if let currentForecast = vm.currentForecast,
                            let weather = currentForecast.weather.first
                        {
                            WeatherImageView(
                                condition: weather.weatherCondition,
                                partOfDay: weather.partOfDay,
                                width: 20
                            )
                        }
                    }

                    Spacer()

                    if let currentForecast = vm.currentForecast {
                        HighLowTemperatures(
                            maxTemp: currentForecast.main.tempMax,
                            minTemp: currentForecast.main.tempMin
                        )
                    }
                }
                .font(.caption)
                .fontWeight(.semibold)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.55), radius: 3, x: 0, y: 2)
        }
        .contentShape(Rectangle())
        .listRowSeparator(.hidden)
        .listRowBackground(
            rowBackground
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        )
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .task {
            if isMyLocation {
                vm.setLocationManager(locationManager: locationManager)
            } else if let place {
                vm.setPlace(place: place)
            }

            vm.startDataRefreshTimer()
        }
        .onReceive(
            NotificationCenter
                .default
                .publisher(for: UIApplication.didBecomeActiveNotification)
        ) { _ in
            vm.didBecomeActive()
        }
        .onReceive(
            NotificationCenter
                .default
                .publisher(for: UIApplication.willResignActiveNotification)
        ) { _ in
            vm.willResignActive()
        }

        .onDisappear {
            vm.endDataRefreshTimer()
        }
    }

    @ViewBuilder
    private var rowBackground: some View {
        if let forecast = vm.currentForecast,
            let weather = forecast.weather.first
        {
            weather.weatherCondition.getBackgroundImage(
                partOfDay: weather.partOfDay,
                clouds: forecast.clouds.all
            )
        } else {
            Color.black.opacity(0.2)
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()

    LocationViewCell(dependencies: dependencies, isMyLocation: true)
        .appEnvironment(dependencies)
        .preferredColorScheme(.dark)
}
