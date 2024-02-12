//
//  PlistError.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/23/23.
//

import Foundation

enum PlistError: String, Error {
    case parse,
         url,
         path,
         dataNotFound
}

extension PlistError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .parse:
            return NSLocalizedString("Error in parsing a PList.", comment: "parse")
        case .url:
            return NSLocalizedString("Error in finding a url.", comment: "url")
        case .path:
            return NSLocalizedString("Error in finding a path.", comment: "path")
        case .dataNotFound:
            return NSLocalizedString("No PList data found.", comment: "dataNotFound")
        }
    }
}
