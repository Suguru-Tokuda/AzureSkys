//
//  PreviewManager.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Foundation

struct PreviewManager {
    static let weatherForecasetData: WeatherForecastResponse = WeatherForecastResponse(
        statusCode: 200,
        message: 0,
        count: 40,
        list: [
            WeatherForecast(id: 1701118800, visibility: 10000, probabilityOfPrecipitation: 0, main: MainModel(temp: 290.47, feelsLike: 289.28, tempMin: 290.47, tempMax: 290.81, tempKf: -0.34, pressure: 1018, seaLevel: 1018, groundLevel: 1011, humidity: 39), weathers: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")], clouds: Clouds(all: 0), wind: Wind(speed: 0.58, gust: 1.44, deg: 13), rain: Rain(rainVolumeForNext3HoursInMM: 0.14), snow: Snow(snowVolumeForNext3HoursInMM: 22), partOfDay: .day, dateForecasted: "2023-11-27 21:00:00"),
            WeatherForecast(id: 1701118800, visibility: 10000, probabilityOfPrecipitation: 0, main: MainModel(temp: 290.47, feelsLike: 289.28, tempMin: 290.47, tempMax: 290.81, tempKf: -0.34, pressure: 1018, seaLevel: 1018, groundLevel: 1011, humidity: 39), weathers: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")], clouds: Clouds(all: 0), wind: Wind(speed: 0.58, gust: 1.44, deg: 13), rain: Rain(rainVolumeForNext3HoursInMM: 0.14), snow: Snow(snowVolumeForNext3HoursInMM: 22), partOfDay: .day, dateForecasted: "2023-11-28 21:00:00"),
            WeatherForecast(id: 1701118800, visibility: 10000, probabilityOfPrecipitation: 0, main: MainModel(temp: 290.47, feelsLike: 289.28, tempMin: 290.47, tempMax: 290.81, tempKf: -0.34, pressure: 1018, seaLevel: 1018, groundLevel: 1011, humidity: 39), weathers: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")], clouds: Clouds(all: 0), wind: Wind(speed: 0.58, gust: 1.44, deg: 13), rain: Rain(rainVolumeForNext3HoursInMM: 0.14), snow: Snow(snowVolumeForNext3HoursInMM: 22), partOfDay: .day, dateForecasted: "2023-11-29 21:00:00"),
            WeatherForecast(id: 1701118800, visibility: 10000, probabilityOfPrecipitation: 0, main: MainModel(temp: 290.47, feelsLike: 289.28, tempMin: 290.47, tempMax: 290.81, tempKf: -0.34, pressure: 1018, seaLevel: 1018, groundLevel: 1011, humidity: 39), weathers: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")], clouds: Clouds(all: 0), wind: Wind(speed: 0.58, gust: 1.44, deg: 13), rain: Rain(rainVolumeForNext3HoursInMM: 0.14), snow: Snow(snowVolumeForNext3HoursInMM: 22), partOfDay: .day, dateForecasted: "2023-11-230 21:00:00"),
            WeatherForecast(id: 1701118800, visibility: 10000, probabilityOfPrecipitation: 0, main: MainModel(temp: 290.47, feelsLike: 289.28, tempMin: 290.47, tempMax: 290.81, tempKf: -0.34, pressure: 1018, seaLevel: 1018, groundLevel: 1011, humidity: 39), weathers: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")], clouds: Clouds(all: 0), wind: Wind(speed: 0.58, gust: 1.44, deg: 13), rain: Rain(rainVolumeForNext3HoursInMM: 0.14), snow: Snow(snowVolumeForNext3HoursInMM: 22), partOfDay: .day, dateForecasted: "2023-11-27 21:00:00")
        ],
        city: City(
            id: 5341145,
            population: 58302,
            timezone: -28800,
            coordinate: CityCoordinate(lat: 37.3323, lon: -122.0312),
            name: "Cupertino",
            country: "US",
            sunrise: 1701097189,
            sunset: 1701132722))
    
    static let predictions: [Prediction] = [
        Prediction(id: UUID(), description: "Chicago IL, USA", placeId: "ChIJ7cv00DwsDogRAMDACa2m4K8", structuredFormatting: StructuredFormatting(mainText: "Chicago", secondaryText: "IL, USA"))
    ]
    
    static let placeDetails: GooglePlaceDetailsResult = GooglePlaceDetailsResult(formattedAddress: "Chicago, IL, USA", geometory: GooglePlaceGeometry(location: GooglePlaceLocation(latitude: 41.8781136, longitude: -87.6297982)))
}
