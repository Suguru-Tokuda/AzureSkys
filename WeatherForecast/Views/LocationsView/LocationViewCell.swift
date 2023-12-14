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
    var place: GooglePlaceDetails?
    var isMyLocation: Bool = false
    
    init(place: GooglePlaceDetails? = nil, isMyLocation: Bool = false) {
        self.isMyLocation = isMyLocation
        self.place = place
    }
    
    var body: some View {
        ZStack {
            if vm.isLoading {
                ProgressView("Loading...")
            }
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        // MARK: Location Text
                        Text(isMyLocation ? "My Location" : place?.name ?? "")
                            .font(.title3)
                            .fontWeight(.bold)
                        // MARK: Time
                        Text(isMyLocation ? vm.currentForecast?.name ?? "" : vm.currentForecast?.dateTime.unixTimeToDateStr(dateFormat: Constants.dateFormat).getDateStrinng(dateFormat: Constants.dateFormat, newDateFormat: "hh:mm") ?? "")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    if let currentForecast = vm.currentForecast {
                        // MARK: Degree
                        Text(currentForecast.main.temp.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())
                            .font(.largeTitle)
                    }
                }
                Spacer()
                    .frame(height: 25)
                HStack {
                    HStack {
                        Text(vm.currentForecast?.weather.first?.main ?? "-")
                        if let currentForecast = vm.currentForecast,
                           let weather = currentForecast.weather.first {
                            AsyncImage(url: URL(string: Constants.weatherIconURL.replacingOccurrences(of: "ICON_CODE", with: weather.icon))) { img in
                                img
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    
                    Spacer()
                    if let currentForecast = vm.currentForecast {
                        HighLowTemperatures(maxTemp: currentForecast.main.tempMax, minTemp: currentForecast.main.tempMin)
                    }
                }
                .font(.caption)
                .fontWeight(.semibold)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(
            vm.listRowBackground
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
                if let place {
                    vm.setPlace(place: place)
                    await vm.getCurrentWeatherDataWithCityData()
                }
            }
        }
    }
}

#Preview {
    LocationViewCell(isMyLocation: true)
        .environmentObject(LocationManager())
        .preferredColorScheme(.dark)
}
