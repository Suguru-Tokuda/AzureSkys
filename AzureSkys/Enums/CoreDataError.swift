//
//  CoreDataError.swift
//  AzureSkys
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
            return NSLocalizedString(CoreDataErrorConstants.coreDataSaveError, comment: "save")
        case .fetch:
            return NSLocalizedString(CoreDataErrorConstants.coreDataFetchError, comment: "fetch")
        case .delete:
            return NSLocalizedString(CoreDataErrorConstants.coreDataDeleteError, comment: "delete")
        }
    }
}

private enum CoreDataErrorConstants {
    static let coreDataSaveError = "Error with saving to core data."
    static let coreDataFetchError = "Error with fetching from core data."
    static let coreDataDeleteError = "Error with deleting from core data."
}
