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
            return NSLocalizedString("Bad URL Error. Please make sure the URL is valid.", comment: "badUrl")
        case .dataParsingError:
            return NSLocalizedString("Data Processing Error", comment: "dataParsingError")
        case .serverError:
            return NSLocalizedString("Server Error", comment: "serverError")
        case .noData:
            return NSLocalizedString("No data found.", comment: "noData")
        case .networkUnavailable:
            return NSLocalizedString("Network connection unavailable", comment: "networkUnavailable")
        case .unknown:
            return NSLocalizedString("Unknown error.", comment: "unknown")
        }
    }
}
