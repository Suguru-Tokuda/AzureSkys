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
            return NSLocalizedString(Strings.dataParsingError.rawValue, comment: Strings.data.rawValue)
        case .badPath:
            return NSLocalizedString(Strings.filePathError.rawValue, comment: Strings.badPath.rawValue)
        case .save:
            return NSLocalizedString(Strings.fileSaveError.rawValue, comment: Strings.save.rawValue)
        case .retrieve:
            return NSLocalizedString(Strings.fileRetrieveError.rawValue, comment: Strings.retrieve.rawValue)
        }
    }
}
