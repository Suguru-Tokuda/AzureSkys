//
//  FileManagerError.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/15/23.
//

import Foundation

enum FileManagerError: Error {
    case data,
         badPath,
         save,
         retrieve
}

extension FileManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .data:
            return NSLocalizedString("Error in parsing to data.", comment: "data")
        case .badPath:
            return NSLocalizedString("Could not find a path to the file.", comment: "badPath")
        case .save:
            return NSLocalizedString("Error in saving data.", comment: "save")
        case .retrieve:
            return NSLocalizedString("Error in retrieving data.", comment: "retrieve")
        }
    }
}
