//
//  ApiKeyModel.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/23/23.
//

import Foundation

struct ApiKeyModel: Decodable {
    let googleApiKey: String
    let openWeatherApiKey: String
    
    enum CodingKeys: String, CodingKey {
        case googleApiKey = "GOOGLE_API_KEY"
        case openWeatherApiKey = "OPEN_WEATHER_API_KEY"
    }
}
