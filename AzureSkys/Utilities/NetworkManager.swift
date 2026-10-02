//
//  NetworkManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Foundation
import Network
import Combine

protocol Networking {
    func getData<T: Decodable>(url: URL, type: T.Type) -> AnyPublisher<T, Error>
    func getData<T: Decodable>(url: URL?, type: T.Type, completionHandler: @escaping (Result<T, Error>) -> Void)
    func getData<T: Decodable>(url: URL?, type: T.Type) async throws -> T
    func checkNetworkAvailability(queue: DispatchQueue, completionHandler: @escaping ((Bool) -> ()))
    func checkNetworkAvailability(queue: DispatchQueue) async -> Bool
}

class NetworkManager: Networking {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getData<T: Decodable>(url: URL?, type: T.Type, completionHandler: @escaping (Result<T, Error>) -> Void) {
        guard let url else {
            completionHandler(.failure(NetworkError.badUrl))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error {
                completionHandler(.failure(error))
                return
            }

            completionHandler(Result {
                try Self.decode(data: data ?? Data(), response: response, type: T.self)
            })
        }
        .resume()
    }

    func getData<T: Decodable>(url: URL?, type: T.Type) async throws -> T {
        guard let url else { throw NetworkError.badUrl }

        let (data, response) = try await session.data(from: url)
        return try Self.decode(data: data, response: response, type: type)
    }

    func getData<T: Decodable>(url: URL, type: T.Type) -> AnyPublisher<T, Error> {
        session.dataTaskPublisher(for: url)
            .tryMap { result in
                try Self.decode(data: result.data, response: result.response, type: type)
            }
            .eraseToAnyPublisher()
    }

    private static func decode<T: Decodable>(data: Data, response: URLResponse?, type: T.Type) throws -> T {
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode) else {
            throw NetworkError.serverError
        }
        guard !data.isEmpty else { throw NetworkError.noData }

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw NetworkError.dataParsingError
        }
    }
}

// MARK: Default implementations

extension Networking {
    func checkNetworkAvailability(queue: DispatchQueue = DispatchQueue.global(qos: .background), completionHandler: @escaping ((Bool) -> ())) {
        let monitor = NWPathMonitor()
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
            monitor.cancel()
        }
    }

    func checkNetworkAvailability(queue: DispatchQueue = DispatchQueue.global(qos: .background)) async -> Bool {
        return await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            
            monitor.pathUpdateHandler = { path in
                monitor.cancel()  // Stop monitoring after getting the status
                continuation.resume(returning: path.status == .satisfied)
            }
            
            monitor.start(queue: queue)
        }
    }
}
