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
            return NSLocalizedString(NetworkErrorConstants.badURLError, comment: "badUrl")
        case .dataParsingError:
            return NSLocalizedString(NetworkErrorConstants.dataProcessingError, comment: "dataParsingError")
        case .serverError:
            return NSLocalizedString(NetworkErrorConstants.serverError, comment: "serverError")
        case .noData:
            return NSLocalizedString(NetworkErrorConstants.noDataFound, comment: "noData")
        case .networkUnavailable:
            return NSLocalizedString(NetworkErrorConstants.networkConnectionUnavailable, comment: "networkUnavailable")
        case .unknown:
            return NSLocalizedString(NetworkErrorConstants.unknownError, comment: "unknown")
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

private enum NetworkErrorConstants {
    static let badURLError = "Bad URL Error. Please make sure the URL is valid."
    static let dataProcessingError = "Data Processing Error"
    static let serverError = "Server Error"
    static let noDataFound = "No data found."
    static let networkConnectionUnavailable = "Network connection unavailable"
    static let unknownError = "Unknown error."
}
