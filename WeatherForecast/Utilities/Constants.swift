//
//  Constants.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Foundation

struct Constants {
    static let googleApiKey = "YOUR_API_KEY"
    static let weatherApiKey = "YOUR_API_KEY"
    
    static let weatherApiEndpoint = "https://api.openweathermap.org/data/2.5/forecast"
    static let googleApiBaseURL = "https://maps.googleapis.com/maps/api/place/"
    
    static let weatherIconURL = "https://openweathermap.org/img/wn/ICON_CODE@2x.png"
    static let weatherApiURL = "\(weatherApiEndpoint)?lat={LAT}&lon={LON}&appid=\(weatherApiKey)"
    static let autoCompleteURL = "\(googleApiBaseURL)autocomplete/json?input={INPUT}&types=%28cities%29&fields=place_id%29description"
    
    static let dateFormat = "yyyy-MM-dd HH:mm:ss"
}
