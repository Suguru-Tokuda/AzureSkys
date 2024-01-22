//
//  NetworkManager.swift
//  WeatherForecast
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
}

class NetworkManager: Networking {
    func getData<T>(url: URL?, type: T.Type, completionHandler: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        guard let url else {
            completionHandler(.failure(NetworkError.badUrl))
            return
        }
        
        URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            if let data,
                let res = response as? HTTPURLResponse,
                200..<300 ~= res.statusCode {
                do {
                    let parsedData = try JSONDecoder().decode(type.self, from: data)
                    
                    completionHandler(.success(parsedData))
                } catch {
                    completionHandler(.failure(NetworkError.serverError))
                }
            } else {
                completionHandler(.failure(NetworkError.serverError))
            }
        }
        .resume()
    }
    
    func getData<T>(url: URL?, type: T.Type) async throws -> T where T : Decodable {
        guard let url else { throw NetworkError.badUrl }
        
        do {
            let (rawData, response) = try await URLSession.shared.data(for: URLRequest(url: url))
            
            if rawData.isEmpty { throw NetworkError.noData }
            if let res = response as? HTTPURLResponse,
               res.statusCode >= 200 && res.statusCode < 300 { // consider 2XX status code is success
                do {
                    return try JSONDecoder().decode(type, from: rawData)
                } catch {
                    throw NetworkError.dataParsingError
                }
            } else {
                throw NetworkError.serverError
            }
        } catch {
            throw NetworkError.serverError
        }
    }
    
    func getData<T>(url: URL, type: T.Type) -> AnyPublisher<T, Error> where T : Decodable {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { val in
                if let response = val.response as? HTTPURLResponse,
                   response.statusCode >= 200 && response.statusCode < 300 {
                    throw NetworkError.serverError
                }
                
                if val.data.isEmpty {
                    throw NetworkError.noData
                }
                
                return val.data
            }
            .decode(type: type.self, decoder: JSONDecoder())
            .mapError({ error in
                switch error {
                case is Swift.DecodingError:
                    return NetworkError.dataParsingError
                default:
                    return NetworkError.unknown
                }
            })
            .eraseToAnyPublisher()
    }
    
    func checkNetworkAvailability(queue: DispatchQueue, completionHandler: @escaping ((Bool) -> ())) {
        let monitor = NWPathMonitor()
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
}
