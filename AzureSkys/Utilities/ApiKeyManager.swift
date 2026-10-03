//
//  ApiKeyManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/23/23.
//

import Foundation

protocol PlistActions {
    var resourceBundle: Bundle { get }
    func getData<T: Decodable>(resource: String, type: T.Type) throws -> T
}

extension PlistActions {
    var resourceBundle: Bundle { .main }
    func getData<T: Decodable>(resource: String = "ApiKeys", type: T.Type = ApiKeyModel.self) throws -> T {
        do {
            if let url = resourceBundle.url(forResource: resource, withExtension: "plist") {
                var data: Data
                
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    throw PlistError.url
                }
                
                do {
                    let retVal = try PropertyListDecoder().decode(type.self, from: data)
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
}

protocol ApiKeyActions {
    func getGoogleApiKey() throws -> String
    func getOpenWeatherApiKey() throws -> String
}

class ApiKeyManager: ApiKeyActions, PlistActions {
    let resourceBundle: Bundle
    private let resource: String

    init(bundle: Bundle = .main, resource: String = "ApiKeys") {
        self.resourceBundle = bundle
        self.resource = resource
    }

    func getGoogleApiKey() throws -> String {
        do {
            let apiKeyModel = try self.getData(resource: resource, type: ApiKeyModel.self)
            return apiKeyModel.googleApiKey
        } catch {
            throw PlistError.dataNotFound
        }
    }
    
    func getOpenWeatherApiKey() throws -> String {
        do {
            let apiKeyModel = try self.getData(resource: resource, type: ApiKeyModel.self)
            return apiKeyModel.openWeatherApiKey
        } catch {
            throw PlistError.dataNotFound
        }
    }
}
