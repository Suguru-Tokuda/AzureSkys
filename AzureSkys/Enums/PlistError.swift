//
//  PlistError.swift
//  AzureSkys
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
            return NSLocalizedString(PlistErrorConstants.plistParsingError, comment: "parse")
        case .url:
            return NSLocalizedString(PlistErrorConstants.plistURLError, comment: "url")
        case .path:
            return NSLocalizedString(PlistErrorConstants.plistPathError, comment: "path")
        case .dataNotFound:
            return NSLocalizedString(PlistErrorConstants.plistDataNotFound, comment: "dataNotFound")
        }
    }
}

private enum PlistErrorConstants {
    static let plistParsingError = "Error in parsing a PList."
    static let plistURLError = "Error in finding a url."
    static let plistPathError = "Error in finding a path."
    static let plistDataNotFound = "No PList data found."
}
