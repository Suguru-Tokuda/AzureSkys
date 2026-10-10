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
            return NSLocalizedString(Strings.coreDataSaveError.rawValue, comment: "save")

        case .fetch:
            return NSLocalizedString(Strings.coreDataFetchError.rawValue, comment: "fetch")

        case .delete:
            return NSLocalizedString(Strings.coreDataDeleteError.rawValue, comment: "delete")
        }
    }
}
