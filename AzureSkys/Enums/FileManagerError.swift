//
//  FileManagerError.swift
//  AzureSkys
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
            return NSLocalizedString(Strings.dataParsingError.rawValue, comment: "data")

        case .badPath:
            return NSLocalizedString(Strings.filePathError.rawValue, comment: "badPath")

        case .save:
            return NSLocalizedString(Strings.fileSaveError.rawValue, comment: "save")

        case .retrieve:
            return NSLocalizedString(Strings.fileRetrieveError.rawValue, comment: "retrieve")
        }
    }
}
