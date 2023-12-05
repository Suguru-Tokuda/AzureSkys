//
//  WeatherForecastResponse.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Foundation

struct WeatherForecastResponse: Decodable {
    let statusCode, message, count: Int
    let list: [WeatherForecast]
    let city: City
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "cod"
        case message
        case count = "cnt"
        case list
        case city
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusCode = Int(try container.decode(String.self, forKey: .statusCode)) ?? 0
        self.message = try container.decode(Int.self, forKey: .message)
        self.count = try container.decode(Int.self, forKey: .count)
        self.list = try container.decode([WeatherForecast].self, forKey: .list)
        self.city = try container.decode(City.self, forKey: .city)
    }

    init(statusCode: Int, message: Int, count: Int, list: [WeatherForecast], city: City) {
        self.statusCode = statusCode
        self.message = message
        self.count = count
        self.list = list
        self.city = city
    }

    func getDailyForecast() -> [WeatherForecast] {
        var retVal: [WeatherForecast] = []
        
        let count = list.count
        var i = 0
        
        while i < count {
            retVal.append(list[i])
            
            i += 8
        }
        
        return retVal
    }
}

struct WeatherForecast: Decodable, Identifiable {
    let id: Int
    let visibility: Int
    let probabilityOfPrecipitation: Double
    let main: MainModel
    let weathers: [Weather]
    let clouds: Clouds?
    let wind: Wind?
    let rain: Rain?
    let snow: Snow?
    let partOfDay: PartOfDay
    let dateForecasted: String
        
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "dt"
        case visibility
        case probabilityOfPrecipitation = "pop"
        case main
        case weathers = "weather"
        case clouds
        case wind
        case rain
        case snow
        case partOfDay = "sys"
        case dateForecasted = "dt_txt"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.visibility = try container.decode(Int.self, forKey: .visibility)
        self.probabilityOfPrecipitation = try container.decode(Double.self, forKey: .probabilityOfPrecipitation)
        self.main = try container.decode(MainModel.self, forKey: .main)
        self.weathers = try container.decode([Weather].self, forKey: .weathers)
        self.clouds = try container.decodeIfPresent(Clouds.self, forKey: .clouds)
        self.wind = try container.decodeIfPresent(Wind.self, forKey: .wind)
        self.rain = try container.decodeIfPresent(Rain.self, forKey: .rain)
        self.snow = try container.decodeIfPresent(Snow.self, forKey: .snow)
        let pod = try container.decodeIfPresent(PartOfDayModel.self, forKey: .partOfDay)
        self.partOfDay = pod?.pod == "d" ? PartOfDay.day : PartOfDay.night
        self.dateForecasted = try container.decode(String.self, forKey: .dateForecasted)
    }
    
    init(id: Int, visibility: Int, probabilityOfPrecipitation: Double, main: MainModel, weathers: [Weather], clouds: Clouds, wind: Wind, rain: Rain, snow: Snow, partOfDay: PartOfDay, dateForecasted: String) {
        self.id = id
        self.visibility = visibility
        self.probabilityOfPrecipitation = probabilityOfPrecipitation
        self.main = main
        self.weathers = weathers
        self.clouds = clouds
        self.wind = wind
        self.rain = rain
        self.snow = snow
        self.partOfDay = partOfDay
        self.dateForecasted = dateForecasted
    }
}

struct MainModel: Decodable {
    let temp, feelsLike, tempMin, tempMax, tempKf: Double
    let pressure, seaLevel, groundLevel, humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp,
             feelsLike = "feels_like",
             tempMin = "temp_min",
             tempMax = "temp_max",
             pressure,
             seaLevel = "sea_level",
             groundLevel = "grnd_level",
             humidity,
             tempKf = "temp_kf"
    }
}

struct Weather: Decodable, Identifiable {
    let id: Int
    let main, description, icon: String
}

struct Clouds: Decodable {
    let all: Int
}

struct Wind: Decodable {
    let speed, gust: Double
    let deg: Int
}

struct Rain: Decodable {
    let rainVolumeForNext3HoursInMM: Double
    
    enum CodingKeys: String, CodingKey {
        case rainVolumeForNext3HoursInMM = "3h"
    }
}

struct Snow: Decodable {
    let snowVolumeForNext3HoursInMM: Double
    
    enum CodingKeys: String, CodingKey {
        case snowVolumeForNext3HoursInMM = "3h"
    }
}

struct City: Identifiable, Decodable {
    let id, population, timezone: Int
    let coordinate: CityCoordinate
    let name, country: String
    let sunrise, sunset: Double
    
    enum CodingKeys: String, CodingKey {
        case id, 
             name,
             coordinate = "coord",
             country,
             population,
             timezone,
             sunrise,
             sunset
    }
}

struct CityCoordinate: Decodable {
    let lat, lon: Double
}

struct PartOfDayModel: Decodable {
    let pod: String
}

enum PartOfDay: String, Decodable {
    case night, day
}
