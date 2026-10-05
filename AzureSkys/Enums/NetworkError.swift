//
//  NetworkError.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Foundation

enum NetworkError: Error {
    case badUrl,
         dataParsingError,
         serverError,
         noData,
         networkUnavailable,
         unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badUrl:
            return NSLocalizedString(Strings.badURLError.rawValue, comment: "badUrl")
        case .dataParsingError:
            return NSLocalizedString(Strings.dataProcessingError.rawValue, comment: "dataParsingError")
        case .serverError:
            return NSLocalizedString(Strings.serverError.rawValue, comment: "serverError")
        case .noData:
            return NSLocalizedString(Strings.noDataFound.rawValue, comment: "noData")
        case .networkUnavailable:
            return NSLocalizedString(Strings.networkConnectionUnavailable.rawValue, comment: "networkUnavailable")
        case .unknown:
            return NSLocalizedString(Strings.unknownError.rawValue, comment: "unknown")
        }
    }
}

extension NetworkError {
    init(_ error: Error) {
        if let error = error as? NetworkError {
            self = error
        } else if let error = error as? URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                self = .networkUnavailable
            case .badURL, .unsupportedURL:
                self = .badUrl
            default:
                self = .unknown
            }
        } else if error is DecodingError {
            self = .dataParsingError
        } else {
            self = .unknown
        }
    }
}
