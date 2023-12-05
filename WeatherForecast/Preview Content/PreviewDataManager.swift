//
//  LocalNetworkManager.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import Foundation

protocol PreviewData {
    func getData<T>(resourceName: String, format: String, type: T.Type) async throws -> T where T : Decodable
}

class PreviewDataManager: PreviewData {
    func getData<T>(resourceName: String, format: String, type: T.Type) async throws -> T where T : Decodable {
        if let path = Bundle.main.url(forResource: resourceName, withExtension: format) {
            do {
                let data = try Data(contentsOf: path)
                return try JSONDecoder().decode(type.self, from: data)
            } catch {
                print(error)
                throw error
            }
        } else {
            throw NetworkError.unknown
        }
    }
}
