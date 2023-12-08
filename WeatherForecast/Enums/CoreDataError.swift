//
//  CoreDataError.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/7/23.
//

import Foundation

enum CoreDataError: Error {
    case save, fetch, delete
}

extension CoreDataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .save:
            return NSLocalizedString("Error with saving to core data.", comment: "save")
        case .fetch:
            return NSLocalizedString("Error with fetching from core data.", comment: "fetch")
        case .delete:
            return NSLocalizedString("Error with deleting from core data.", comment: "delete")
        }
    }
}
