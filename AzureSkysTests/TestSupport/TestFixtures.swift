//
//  TestFixtures.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import Foundation
@testable import AzureSkys

enum TestFixtures {
    static let oneCallData = Data(#"{"lat":12.5,"lon":-34.5,"timezone":"UTC","timezone_offset":0,"current":{"dt":1700000000,"sunrise":1699990000,"sunset":1700030000,"temp":280.0,"feels_like":279.0,"pressure":1000,"humidity":70,"dew_point":275.0,"uvi":3.0,"clouds":20,"visibility":10000,"wind_speed":5.0,"wind_deg":90,"wind_gust":7.0,"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01d"}],"pop":0.2},"hourly":[{"dt":1700000000,"sunrise":1699990000,"sunset":1700030000,"temp":280.0,"feels_like":279.0,"pressure":1000,"humidity":70,"dew_point":275.0,"uvi":3.0,"clouds":20,"visibility":10000,"wind_speed":5.0,"wind_deg":90,"wind_gust":7.0,"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01d"}],"pop":0.2}],"daily":[{"dt":1700000000,"sunrise":1699990000,"sunset":1700030000,"moonrise":1700020000,"moonset":1700040000,"moon_phase":0.5,"summary":"Clear skies","temp":{"day":280,"min":278,"max":282,"night":279,"eve":280,"morn":278},"feels_like":{"day":279,"night":278,"eve":279,"morn":277},"pressure":1000,"humidity":70,"dew_point":275.0,"wind_speed":5.0,"wind_deg":90,"wind_gust":7.0,"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01d"}],"clouds":20,"pop":0.2,"uvi":3.0}]}"#.utf8)
    static let currentData = Data(#"{"id":1,"dt":1700000000,"coord":{"lat":12.5,"lon":-34.5},"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01d"}],"main":{"temp":280.0,"feels_like":279.0,"temp_min":278.0,"temp_max":282.0,"pressure":1000,"sea_level":1010,"grnd_level":990,"humidity":70,"temp_kf":0.0},"visibility":10000,"wind":{"speed":5,"gust":7,"deg":90},"clouds":{"all":20},"sys":{"type":1,"id":1,"sunrise":1699990000,"sunset":1700030000,"country":"US"},"timezone":0,"name":"Test City","cod":200}"#.utf8)
    static let legacyData = Data(#"{"cod":"200","message":0,"cnt":1,"list":[{"dt":1700000000,"visibility":10000,"pop":0.2,"main":{"temp":280.0,"feels_like":279.0,"temp_min":278.0,"temp_max":282.0,"pressure":1000,"sea_level":1010,"grnd_level":990,"humidity":70,"temp_kf":0.0},"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01d"}],"clouds":{"all":20},"wind":{"speed":5,"gust":7,"deg":90},"rain":{"3h":1.5},"snow":{"3h":0.5},"sys":{"pod":"d"},"dt_txt":"2023-11-14 22:13:20"}],"city":{"id":1,"name":"Test City","country":"US","coord":{"lat":12.5,"lon":-34.5},"timezone":0,"sunrise":1699990000,"sunset":1700030000,"population":10000}}"#.utf8)

    static func oneCall() throws -> WeatherForecastOneCallResponse { try JSONDecoder().decode(WeatherForecastOneCallResponse.self, from: oneCallData) }

    static func current() throws -> WeatherForecastCurrentResponse { try JSONDecoder().decode(WeatherForecastCurrentResponse.self, from: currentData) }

    static func object(_ data: Data) throws -> [String: Any] { try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any]) }

    static func data(_ object: Any) throws -> Data { try JSONSerialization.data(withJSONObject: object) }
}
