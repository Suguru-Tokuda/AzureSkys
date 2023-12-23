//
//  ApiKeyManager.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/23/23.
//

import Foundation

protocol ApiKeyActions {
    func getGoogleApiKey() throws -> String
    func getOpenWeatherApiKey() throws -> String
}

class ApiKeyManager: ApiKeyActions {
    private func getApiModel() throws -> ApiKeyModel {
        do {
            if let url = Bundle.main.url(forResource: "ApiKeys", withExtension: "plist") {
                var data: Data
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    throw PlistError.url
                }
                
                do {
                    let retVal = try PropertyListDecoder().decode(ApiKeyModel.self, from: data)
                    return retVal
                } catch {
                    throw PlistError.parse
                }
            } else {
                throw PlistError.url
            }
        } catch {
            throw PlistError.url
        }
    }
    
    func getGoogleApiKey() throws -> String {
        do {
            let apiKeyModel = try self.getApiModel()
            return apiKeyModel.googleApiKey
        } catch {
            throw PlistError.dataNotFound
        }
    }
    
    func getOpenWeatherApiKey() throws -> String {
        do {
            let apiKeyModel = try self.getApiModel()
            return apiKeyModel.openWeatherApiKey
        } catch {
            throw PlistError.dataNotFound
        }
    }
}
