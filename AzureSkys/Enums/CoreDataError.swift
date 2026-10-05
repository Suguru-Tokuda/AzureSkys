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
            return NSLocalizedString(Strings.coreDataSaveError.rawValue, comment: Strings.save.rawValue)
        case .fetch:
            return NSLocalizedString(Strings.coreDataFetchError.rawValue, comment: Strings.fetch.rawValue)
        case .delete:
            return NSLocalizedString(Strings.coreDataDeleteError.rawValue, comment: Strings.delete.rawValue)
        }
    }
}
