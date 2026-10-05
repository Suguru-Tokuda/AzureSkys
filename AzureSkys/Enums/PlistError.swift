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
            return NSLocalizedString(Strings.plistParsingError.rawValue, comment: "parse")
        case .url:
            return NSLocalizedString(Strings.plistURLError.rawValue, comment: "url")
        case .path:
            return NSLocalizedString(Strings.plistPathError.rawValue, comment: "path")
        case .dataNotFound:
            return NSLocalizedString(Strings.plistDataNotFound.rawValue, comment: "dataNotFound")
        }
    }
}
