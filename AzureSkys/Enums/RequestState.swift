//
//  RequestState.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import Foundation

enum RequestState<Value> {
    case idle
    case loading(previous: Value? = nil)
    case loaded(Value)
    case failed(NetworkError, previous: Value? = nil)

    var value: Value? {
        switch self {
        case .idle: return nil
        case .loading(let previous), .failed(_, let previous): return previous
        case .loaded(let value): return value
        }
    }

    var error: NetworkError? {
        if case .failed(let error, _) = self { return error }
        return nil
    }

    var loadingStatus: LoadingStatus {
        switch self {
        case .idle, .failed: return .inactive
        case .loading(let previous): return previous == nil ? .loading : .loaded
        case .loaded: return .loaded
        }
    }

    mutating func dismissError() {
        guard error != nil else { return }
        self = value.map(Self.loaded) ?? .idle
    }
}
