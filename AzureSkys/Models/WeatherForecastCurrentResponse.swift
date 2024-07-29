//
//  AzureSkysCurrentResponse.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import Foundation

struct WeatherForecastCurrentResponse: Decodable, Identifiable {
    let id: Int
    let dateTime: Int
    let coordinate: WeatherForecastCoordinate
    let weather: [Weather]
    let main: MainModel
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let system: System
    let timezone: Int
    let name: String
    let cod: Int
    
    enum CodingKeys: String, CodingKey {
        case id, 
             dateTime = "dt",
             coordinate = "coord",
             weather,
             main,
             visibility,
             wind,
             clouds,
             system = "sys",
             timezone,
             name,
             cod
    }
}

struct WeatherForecastCoordinate: Decodable {
    let longitude, latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

struct System: Decodable {
    let type, id: Int
    let sunrise, sunset: Double
    let country: String
}
