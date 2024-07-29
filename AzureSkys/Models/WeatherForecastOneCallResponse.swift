//
//  AzureSkysOneCallResponse.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/12/23.
//

import Foundation

struct WeatherForecastOneCallResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let timezoneOffset: Int
    let current: Forecast
    let hourly: [Forecast]
    let daily: [DailyForecast]
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat",
             longitude = "lon",
             timezone,
             timezoneOffset = "timezone_offset",
             current,
             hourly,
             daily
    }
}

struct Forecast: Decodable, Identifiable {
    let id = UUID()
    let dateTime: Int
    let sunrise: Int?
    let sunset: Int?
    let temp: Double
    let feelsLike: Double
    let pressure: Int?
    let humidity: Int?
    let dewPoint: Double?
    let uvi: Float?
    let clouds: Int?
    let visibility: Int?
    let windSpeed: Double
    let windDeg: Int?
    let windGust: Double?
    let weather: [Weather]
    let probabilityOfPrecipitation: Float?
    
    enum CodingKeys: String, CodingKey {
        case dateTime = "dt"
        case sunrise
        case sunset
        case temp
        case feelsLike = "feels_like"
        case pressure
        case humidity
        case dewPoint = "dew_point"
        case uvi
        case clouds
        case visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather
        case probabilityOfPrecipitation = "pop"
    }
}

struct DailyForecast: Decodable, Identifiable {
    let id = UUID()
    let dateTime, sunrise, sunset, moonrise: Int
    let moonset: Int
    let moonPhase: Float
    let summary: String
    let temp: Temp
    let feelsLike: FeelsLike
    let pressure, humidity: Int
    let dewPoint, windSpeed: Double
    let windDeg: Int
    let windGust: Double
    let weather: [Weather]
    let clouds: Int
    let probabilityOfPrecipitation: Float
    let uvi: Double

    enum CodingKeys: String, CodingKey {
        case dateTime = "dt"
        case sunrise, sunset, moonrise, moonset
        case moonPhase = "moon_phase"
        case summary, temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case probabilityOfPrecipitation = "pop"
        case weather, clouds, uvi
    }
}

// MARK: - FeelsLike
struct FeelsLike: Codable {
    let day, night, eve, morn: Double
}

// MARK: - Temp
struct Temp: Codable {
    let day, min, max, night: Double
    let eve, morn: Double
}
