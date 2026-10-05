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
            return NSLocalizedString(Strings.badURLError.rawValue, comment: Strings.badUrl.rawValue)
        case .dataParsingError:
            return NSLocalizedString(Strings.dataProcessingError.rawValue, comment: Strings.dataParsingErrorComment.rawValue)
        case .serverError:
            return NSLocalizedString(Strings.serverError.rawValue, comment: Strings.serverErrorComment.rawValue)
        case .noData:
            return NSLocalizedString(Strings.noDataFound.rawValue, comment: Strings.noData.rawValue)
        case .networkUnavailable:
            return NSLocalizedString(Strings.networkConnectionUnavailable.rawValue, comment: Strings.networkUnavailable.rawValue)
        case .unknown:
            return NSLocalizedString(Strings.unknownError.rawValue, comment: Strings.unknown.rawValue)
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
