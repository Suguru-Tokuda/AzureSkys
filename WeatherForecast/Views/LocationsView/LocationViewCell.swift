//
//  LocationViewCell.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

struct LocationViewCell: View {
    @AppStorage(AppStorageKeys.tempScale) var tempScale: TempScale = .fahrenheit
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var vm: CurrentWeatherForecastViewModel = CurrentWeatherForecastViewModel()
    var city: City?
    var isMyLocation: Bool = false
    
    init(city: City? = nil, isMyLocation: Bool = false) {
        self.isMyLocation = isMyLocation
        self.city = city
    }
    
    var body: some View {
        ZStack {
            if vm.isLoading {
                ProgressView("Loading...")
            }
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(isMyLocation ? "My Location" : city?.name ?? "")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(isMyLocation ? vm.currentForecast?.name ?? "" : vm.currentForecast?.timezone.getTimeStr(dateFormat: "hh:mm") ?? "")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    if let currentForecast = vm.currentForecast {
                        Text(currentForecast.main.temp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())
                            .font(.largeTitle)
                    }
                }
                Spacer()
                    .frame(height: 25)
                HStack {
                    Text(vm.currentForecast?.weather.first?
                        .main ?? "-")
                    Spacer()
                    HighLowTemperatures(maxTemp: vm.currentForecast?.main.tempMax ?? 0, minTemp: vm.currentForecast?.main.tempMin ?? 0)
                }
                .font(.caption)
                .fontWeight(.semibold)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(
            Color.blue
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        )
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .task {
            if isMyLocation {
                vm.setLocationManager(locationManager: locationManager)
            } else {
                if let city {
                    vm.setCity(city: city)
                    await vm.getCurrentWeatherDataWithCityData()
                }
            }
        }
    }
}

#Preview {
    LocationViewCell(isMyLocation: true)
        .environmentObject(LocationManager())
}
