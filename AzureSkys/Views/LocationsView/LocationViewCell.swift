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
    @StateObject var vm: CurrentWeatherForecastViewModel = CurrentWeatherForecastViewModel()
    @State var isActive: Bool?
    var place: GooglePlaceDetails?
    var isMyLocation: Bool = false
    
    init(place: GooglePlaceDetails? = nil, isMyLocation: Bool = false) {
        self.isMyLocation = isMyLocation
        self.place = place
    }
    
    var body: some View {
        ZStack {
            if vm.loadingStatus == .loading {
                ProgressView("Loading...")
            }
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        // MARK: Location Text
                        Text(isMyLocation ? 
                                "My Location" : 
                                place?.name ?? "")
                            .font(.title3)
                            .fontWeight(.bold)
                        // MARK: Time
                        Text(isMyLocation ? 
                                vm.currentForecast?.name ?? "" :
                                vm.currentForecast?
                                    .dateTime
                                    .unixTimeToDateStr(dateFormat: Constants.dateFormat)
                                    .getDateStrinng(dateFormat: Constants.dateFormat,
                                                    newDateFormat: "hh:mm") ?? "")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    if let currentForecast = vm.currentForecast {
                        // MARK: Degree
                        Text(currentForecast
                                .main
                                .temp
                                .getDegree(tempScale: tempScale)
                                .formatDouble(maxFractions: 0)
                                .appendDegree())
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
                            WeatherImageView(icon: weather.icon, width: 20)
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
            } else if let place {
                vm.setPlace(place: place)
            }
            vm.startDataRefreshTimer()
        }
        .onReceive(NotificationCenter
                    .default
                    .publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if isActive != nil {
                self.isActive = true
                vm.startDataRefreshTimer()
            }
        }
        .onReceive(NotificationCenter
                    .default
                    .publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        isActive = false
        }

        .onDisappear {
            vm.endDataRefreshTimer()
        }
    }
}

#Preview {
    LocationViewCell(isMyLocation: true)
        .environmentObject(LocationManager())
        .environmentObject(LocalFileManager())
        .preferredColorScheme(.dark)
}
