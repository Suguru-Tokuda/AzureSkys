//
//  NetworkError.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Foundation

enum NetworkError: Error {
    case badUrl,
         dataParsingError,
         serverError,
         noData,
         unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
    switch self {
    case .badUrl:
        return NSLocalizedString("Bad URL Error. Please make sure the URL is valid.", comment: "badUrl")
    case .dataParsingError:
        return NSLocalizedString("Data parsing error.", comment: "dataParsingError")
    case .serverError:
        return NSLocalizedString("Server error.", comment: "serverError")
    case .noData:
        return NSLocalizedString("No data found.", comment: "noData")
    case .unknown:
        return NSLocalizedString("Unknown error.", comment: "unknown")
    }
    }
}
