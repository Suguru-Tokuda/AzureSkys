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
            return NSLocalizedString(FileManagerErrorConstants.dataParsingError, comment: "data")
        case .badPath:
            return NSLocalizedString(FileManagerErrorConstants.filePathError, comment: "badPath")
        case .save:
            return NSLocalizedString(FileManagerErrorConstants.fileSaveError, comment: "save")
        case .retrieve:
            return NSLocalizedString(FileManagerErrorConstants.fileRetrieveError, comment: "retrieve")
        }
    }
}

private enum FileManagerErrorConstants {
    static let dataParsingError = "Error in parsing to data."
    static let filePathError = "Could not find a path to the file."
    static let fileSaveError = "Error in saving data."
    static let fileRetrieveError = "Error in retrieving data."
}
