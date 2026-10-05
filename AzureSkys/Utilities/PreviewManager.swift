//
//  PreviewManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Foundation

struct PreviewManager {
    static let geocode: WeatherGeocode = WeatherGeocode(name: Strings.atlanta.rawValue, latitude: 33.7489924, longitude: -84.3902644, country: Strings.previewCountryCode.rawValue, state: Strings.georgia.rawValue)
    static let oneCallResponse: WeatherForecastOneCallResponse = WeatherForecastOneCallResponse(
        latitude: 33.7488,
        longitude: -84.3877,
        timezone: Strings.americaNewYork.rawValue,
        timezoneOffset: -18000,
        current: Forecast(dateTime: 1702388652, sunrise: 1702384375, sunset: 1702420180, temp: 273.19, feelsLike: 269.21, pressure: 1032, humidity: 76, dewPoint: 269.89, uvi: 0.44, clouds: 0, visibility: 10000, windSpeed: 3.6, windDeg: 40, windGust: 1.32, weather: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], probabilityOfPrecipitation: nil),
        hourly: [
            Forecast(dateTime: 1702386000, sunrise: nil, sunset: nil, temp: 273.78, feelsLike: 272.18, pressure: 1032, humidity: 72, dewPoint: 269.76, uvi: 0, clouds: 0, visibility: 10000, windSpeed: 1.46, windDeg: 42, windGust: 3.77, weather: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], probabilityOfPrecipitation: 0),
            Forecast(dateTime: 1702386000, sunrise: nil, sunset: nil, temp: 273.78, feelsLike: 272.18, pressure: 1032, humidity: 72, dewPoint: 269.76, uvi: 0, clouds: 0, visibility: 10000, windSpeed: 1.46, windDeg: 42, windGust: 3.77, weather: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], probabilityOfPrecipitation: 0),
            Forecast(dateTime: 1702386000, sunrise: nil, sunset: nil, temp: 273.78, feelsLike: 272.18, pressure: 1032, humidity: 72, dewPoint: 269.76, uvi: 0, clouds: 0, visibility: 10000, windSpeed: 1.46, windDeg: 42, windGust: 3.77, weather: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], probabilityOfPrecipitation: 0),
            Forecast(dateTime: 1702386000, sunrise: nil, sunset: nil, temp: 273.78, feelsLike: 272.18, pressure: 1032, humidity: 72, dewPoint: 269.76, uvi: 0, clouds: 0, visibility: 10000, windSpeed: 1.46, windDeg: 42, windGust: 3.77, weather: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], probabilityOfPrecipitation: 0),
            Forecast(dateTime: 1702386000, sunrise: nil, sunset: nil, temp: 273.78, feelsLike: 272.18, pressure: 1032, humidity: 72, dewPoint: 269.76, uvi: 0, clouds: 0, visibility: 10000, windSpeed: 1.46, windDeg: 42, windGust: 3.77, weather: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], probabilityOfPrecipitation: 0),
            Forecast(dateTime: 1702386000, sunrise: nil, sunset: nil, temp: 273.78, feelsLike: 272.18, pressure: 1032, humidity: 72, dewPoint: 269.76, uvi: 0, clouds: 0, visibility: 10000, windSpeed: 1.46, windDeg: 42, windGust: 3.77, weather: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], probabilityOfPrecipitation: 0)
        ],
        daily: [
            DailyForecast(
                dateTime: 1702400400,
                sunrise: 1702384375,
                sunset: 1702420180,
                moonrise: 1702383720,
                moonset: 1702418700,
                moonPhase: 0,
                summary: Strings.previewDailySummary.rawValue,
                temp: Temp(day: 284.59, min: 278.26, max: 286.65, night: 281.51, eve: 283.87, morn: 278.45),
                feelsLike: FeelsLike(day: 282.73, night: 280.07, eve: 282.12, morn: 277.3),
                pressure: 1035,
                humidity: 36,
                dewPoint: 270.03,
                windSpeed: 2.45,
                windDeg: 76,
                windGust: 8.04,
                weather: [
                    Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)
                ],
                clouds: 7,
                probabilityOfPrecipitation: 0,
                uvi: 2.76),
            DailyForecast(
                dateTime: 1702400400,
                sunrise: 1702384375,
                sunset: 1702420180,
                moonrise: 1702383720,
                moonset: 1702418700,
                moonPhase: 0,
                summary: Strings.previewDailySummary.rawValue,
                temp: Temp(day: 284.59, min: 278.26, max: 286.65, night: 281.51, eve: 283.87, morn: 278.45),
                feelsLike: FeelsLike(day: 282.73, night: 280.07, eve: 282.12, morn: 277.3),
                pressure: 1035,
                humidity: 36,
                dewPoint: 270.03,
                windSpeed: 2.45,
                windDeg: 76,
                windGust: 8.04,
                weather: [
                    Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)
                ],
                clouds: 7,
                probabilityOfPrecipitation: 0,
                uvi: 2.76),
            DailyForecast(
                dateTime: 1702400400,
                sunrise: 1702384375,
                sunset: 1702420180,
                moonrise: 1702383720,
                moonset: 1702418700,
                moonPhase: 0,
                summary: Strings.previewDailySummary.rawValue,
                temp: Temp(day: 284.59, min: 278.26, max: 286.65, night: 281.51, eve: 283.87, morn: 278.45),
                feelsLike: FeelsLike(day: 282.73, night: 280.07, eve: 282.12, morn: 277.3),
                pressure: 1035,
                humidity: 36,
                dewPoint: 270.03,
                windSpeed: 2.45,
                windDeg: 76,
                windGust: 8.04,
                weather: [
                    Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)
                ],
                clouds: 7,
                probabilityOfPrecipitation: 0,
                uvi: 2.76),
            DailyForecast(
                dateTime: 1702400400,
                sunrise: 1702384375,
                sunset: 1702420180,
                moonrise: 1702383720,
                moonset: 1702418700,
                moonPhase: 0,
                summary: Strings.previewDailySummary.rawValue,
                temp: Temp(day: 284.59, min: 278.26, max: 286.65, night: 281.51, eve: 283.87, morn: 278.45),
                feelsLike: FeelsLike(day: 282.73, night: 280.07, eve: 282.12, morn: 277.3),
                pressure: 1035,
                humidity: 36,
                dewPoint: 270.03,
                windSpeed: 2.45,
                windDeg: 76,
                windGust: 8.04,
                weather: [
                    Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)
                ],
                clouds: 7,
                probabilityOfPrecipitation: 0,
                uvi: 2.76),
            DailyForecast(
                dateTime: 1702400400,
                sunrise: 1702384375,
                sunset: 1702420180,
                moonrise: 1702383720,
                moonset: 1702418700,
                moonPhase: 0,
                summary: Strings.previewDailySummary.rawValue,
                temp: Temp(day: 284.59, min: 278.26, max: 286.65, night: 281.51, eve: 283.87, morn: 278.45),
                feelsLike: FeelsLike(day: 282.73, night: 280.07, eve: 282.12, morn: 277.3),
                pressure: 1035,
                humidity: 36,
                dewPoint: 270.03,
                windSpeed: 2.45,
                windDeg: 76,
                windGust: 8.04,
                weather: [
                    Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)
                ],
                clouds: 7,
                probabilityOfPrecipitation: 0,
                uvi: 2.76),
            DailyForecast(
                dateTime: 1702400400,
                sunrise: 1702384375,
                sunset: 1702420180,
                moonrise: 1702383720,
                moonset: 1702418700,
                moonPhase: 0,
                summary: Strings.previewDailySummary.rawValue,
                temp: Temp(day: 284.59, min: 278.26, max: 286.65, night: 281.51, eve: 283.87, morn: 278.45),
                feelsLike: FeelsLike(day: 282.73, night: 280.07, eve: 282.12, morn: 277.3),
                pressure: 1035,
                humidity: 36,
                dewPoint: 270.03,
                windSpeed: 2.45,
                windDeg: 76,
                windGust: 8.04,
                weather: [
                    Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)
                ],
                clouds: 7,
                probabilityOfPrecipitation: 0,
                uvi: 2.76),
            DailyForecast(
                dateTime: 1702400400,
                sunrise: 1702384375,
                sunset: 1702420180,
                moonrise: 1702383720,
                moonset: 1702418700,
                moonPhase: 0,
                summary: Strings.previewDailySummary.rawValue,
                temp: Temp(day: 284.59, min: 278.26, max: 286.65, night: 281.51, eve: 283.87, morn: 278.45),
                feelsLike: FeelsLike(day: 282.73, night: 280.07, eve: 282.12, morn: 277.3),
                pressure: 1035,
                humidity: 36,
                dewPoint: 270.03,
                windSpeed: 2.45,
                windDeg: 76,
                windGust: 8.04,
                weather: [
                    Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)
                ],
                clouds: 7,
                probabilityOfPrecipitation: 0,
                uvi: 2.76),
            DailyForecast(
                dateTime: 1702400400,
                sunrise: 1702384375,
                sunset: 1702420180,
                moonrise: 1702383720,
                moonset: 1702418700,
                moonPhase: 0,
                summary: Strings.previewDailySummary.rawValue,
                temp: Temp(day: 284.59, min: 278.26, max: 286.65, night: 281.51, eve: 283.87, morn: 278.45),
                feelsLike: FeelsLike(day: 282.73, night: 280.07, eve: 282.12, morn: 277.3),
                pressure: 1035,
                humidity: 36,
                dewPoint: 270.03,
                windSpeed: 2.45,
                windDeg: 76,
                windGust: 8.04,
                weather: [
                    Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)
                ],
                clouds: 7,
                probabilityOfPrecipitation: 0,
                uvi: 2.76),
        ]
    )
    static let weatherForecastData: WeatherForecastResponse = WeatherForecastResponse(
        statusCode: 200,
        message: 0,
        count: 40,
        list: [
            WeatherForecast(id: 1701118800, visibility: 10000, probabilityOfPrecipitation: 0, main: MainModel(temp: 290.47, feelsLike: 289.28, tempMin: 290.47, tempMax: 290.81, tempKf: -0.34, pressure: 1018, seaLevel: 1018, groundLevel: 1011, humidity: 39), weathers: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], clouds: Clouds(all: 0), wind: Wind(speed: 0.58, gust: 1.44, deg: 13), rain: Rain(rainVolumeForNext3HoursInMM: 0.14), snow: Snow(snowVolumeForNext3HoursInMM: 22), partOfDay: .day, dateForecasted: Strings.previewForecastDate1.rawValue),
            WeatherForecast(id: 1701118800, visibility: 10000, probabilityOfPrecipitation: 0, main: MainModel(temp: 290.47, feelsLike: 289.28, tempMin: 290.47, tempMax: 290.81, tempKf: -0.34, pressure: 1018, seaLevel: 1018, groundLevel: 1011, humidity: 39), weathers: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], clouds: Clouds(all: 0), wind: Wind(speed: 0.58, gust: 1.44, deg: 13), rain: Rain(rainVolumeForNext3HoursInMM: 0.14), snow: Snow(snowVolumeForNext3HoursInMM: 22), partOfDay: .day, dateForecasted: Strings.previewForecastDate2.rawValue),
            WeatherForecast(id: 1701118800, visibility: 10000, probabilityOfPrecipitation: 0, main: MainModel(temp: 290.47, feelsLike: 289.28, tempMin: 290.47, tempMax: 290.81, tempKf: -0.34, pressure: 1018, seaLevel: 1018, groundLevel: 1011, humidity: 39), weathers: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], clouds: Clouds(all: 0), wind: Wind(speed: 0.58, gust: 1.44, deg: 13), rain: Rain(rainVolumeForNext3HoursInMM: 0.14), snow: Snow(snowVolumeForNext3HoursInMM: 22), partOfDay: .day, dateForecasted: Strings.previewForecastDate3.rawValue),
            WeatherForecast(id: 1701118800, visibility: 10000, probabilityOfPrecipitation: 0, main: MainModel(temp: 290.47, feelsLike: 289.28, tempMin: 290.47, tempMax: 290.81, tempKf: -0.34, pressure: 1018, seaLevel: 1018, groundLevel: 1011, humidity: 39), weathers: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], clouds: Clouds(all: 0), wind: Wind(speed: 0.58, gust: 1.44, deg: 13), rain: Rain(rainVolumeForNext3HoursInMM: 0.14), snow: Snow(snowVolumeForNext3HoursInMM: 22), partOfDay: .day, dateForecasted: Strings.previewForecastDate4.rawValue),
            WeatherForecast(id: 1701118800, visibility: 10000, probabilityOfPrecipitation: 0, main: MainModel(temp: 290.47, feelsLike: 289.28, tempMin: 290.47, tempMax: 290.81, tempKf: -0.34, pressure: 1018, seaLevel: 1018, groundLevel: 1011, humidity: 39), weathers: [Weather(id: 800, main: Strings.clear.rawValue, description: Strings.clearSky.rawValue, icon: Strings.clearDayIcon.rawValue, partOfDay: .day, weatherCondition: .clear)], clouds: Clouds(all: 0), wind: Wind(speed: 0.58, gust: 1.44, deg: 13), rain: Rain(rainVolumeForNext3HoursInMM: 0.14), snow: Snow(snowVolumeForNext3HoursInMM: 22), partOfDay: .day, dateForecasted: Strings.previewForecastDate1.rawValue)
        ],
        city: City(
            id: 5341145,
            population: 58302,
            timezone: -28800,
            coordinate: CityCoordinate(lat: 37.3323, lon: -122.0312),
            name: Strings.cupertino.rawValue,
            country: Strings.previewCountryCode.rawValue,
            sunrise: 1701097189,
            sunset: 1701132722))
    
    static let predictions: [Prediction] = [
        Prediction(id: UUID(), description: Strings.chicagoILUSA.rawValue, placeId: Strings.previewPlaceID.rawValue, structuredFormatting: StructuredFormatting(mainText: Strings.chicago.rawValue, secondaryText: Strings.previewRegion.rawValue)),
        Prediction(id: UUID(), description: Strings.chicagoILUSA.rawValue, placeId: Strings.previewPlaceID.rawValue, structuredFormatting: StructuredFormatting(mainText: Strings.chicago.rawValue, secondaryText: Strings.previewRegion.rawValue)),
        Prediction(id: UUID(), description: Strings.chicagoILUSA.rawValue, placeId: Strings.previewPlaceID.rawValue, structuredFormatting: StructuredFormatting(mainText: Strings.chicago.rawValue, secondaryText: Strings.previewRegion.rawValue)),
        Prediction(id: UUID(), description: Strings.chicagoILUSA.rawValue, placeId: Strings.previewPlaceID.rawValue, structuredFormatting: StructuredFormatting(mainText: Strings.chicago.rawValue, secondaryText: Strings.previewRegion.rawValue)),
        Prediction(id: UUID(), description: Strings.chicagoILUSA.rawValue, placeId: Strings.previewPlaceID.rawValue, structuredFormatting: StructuredFormatting(mainText: Strings.chicago.rawValue, secondaryText: Strings.previewRegion.rawValue)),
        Prediction(id: UUID(), description: Strings.chicagoILUSA.rawValue, placeId: Strings.previewPlaceID.rawValue, structuredFormatting: StructuredFormatting(mainText: Strings.chicago.rawValue, secondaryText: Strings.previewRegion.rawValue))
    ]
    
    static let placeDetails: GooglePlaceDetails = GooglePlaceDetails(
        id: Strings.previewPlaceID.rawValue,
        formattedAddress: Strings.previewFormattedAddress.rawValue,
        geometry: GooglePlaceGeometry(location: GooglePlaceLocation(latitude: 41.8781136, longitude: -87.6297982)),
        name: Strings.chicago.rawValue,
        addressComponents: [
            GooglePlaceAddressComponent(longName: Strings.chicago.rawValue, shortName: Strings.chicago.rawValue, types: [Strings.locality.rawValue, Strings.political.rawValue]),
            GooglePlaceAddressComponent(longName: Strings.cookCounty.rawValue, shortName: Strings.cookCounty.rawValue, types: [Strings.dministrativeAreaLevel2.rawValue, Strings.political.rawValue]),
            GooglePlaceAddressComponent(longName: Strings.illinois.rawValue, shortName: Strings.previewStateCode.rawValue, types: [Strings.dministrativeAreaLevel1.rawValue, Strings.political.rawValue]),
            GooglePlaceAddressComponent(longName: Strings.unitedState.rawValue, shortName: Strings.previewCountryCode.rawValue, types: [Strings.country.rawValue, Strings.political.rawValue])
        ]
    )
}
