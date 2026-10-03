//
//  ServiceDoubles.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import Foundation
@testable import AzureSkys

import Combine
import CoreLocation

final class TestKeys: ApiKeyActions {
    var fail = false

    func getGoogleApiKey() throws -> String { if fail { throw PlistError.dataNotFound }; return "key&value" }

    func getOpenWeatherApiKey() throws -> String { if fail { throw PlistError.dataNotFound }; return "weather&key" }
}

final class RecordingNetwork: Networking {
    private let lock = NSLock()
    private var requests: [URL] = []
    var available = true
    let response: (URL) throws -> Data
    init(response: @escaping (URL) throws -> Data) { self.response = response }
    var urls: [URL] { lock.lock(); defer { lock.unlock() }; return requests }

    func getData<T: Decodable>(url: URL?, type: T.Type) async throws -> T {
        let url = try XCTUnwrap(url)
        record(url)
        return try JSONDecoder().decode(type, from: response(url))
    }

    private func record(_ url: URL) { lock.lock(); defer { lock.unlock() }; requests.append(url) }

    func getData<T: Decodable>(url: URL, type: T.Type) -> AnyPublisher<T, Error> { Fail(error: NetworkError.unknown).eraseToAnyPublisher() }

    func getData<T: Decodable>(url: URL?, type: T.Type, completionHandler: @escaping (Result<T, Error>) -> Void) {
        Task { do { completionHandler(.success(try await getData(url: url, type: type))) } catch { completionHandler(.failure(error)) } }
    }

    func checkNetworkAvailability(queue: DispatchQueue, completionHandler: @escaping (Bool) -> Void) { completionHandler(available) }

    func checkNetworkAvailability(queue: DispatchQueue) async -> Bool { available }
}

final class WeatherDouble: WeatherServicing {
    var error: Error?
    var pause = false
    var coordinates: [CLLocationCoordinate2D] = []
    var forecast = try! TestFixtures.oneCall()
    var current = try! TestFixtures.current()

    func getForecast(coordinate: CLLocationCoordinate2D) async throws -> WeatherForecastData {
        coordinates.append(coordinate)
        if pause { try await Task.sleep(for: .seconds(10)) }
        if let error { throw error }
        return WeatherForecastData(forecast: forecast, geocode: PreviewManager.geocode)
    }

    func getCurrentWeather(coordinate: CLLocationCoordinate2D) async throws -> WeatherForecastCurrentResponse {
        coordinates.append(coordinate)
        if pause { try await Task.sleep(for: .seconds(10)) }
        if let error { throw error }
        return current
    }
}

final class PlaceStoreDouble: PlaceCoreDataActions {
    var error: Error?
    var saved: [SavedPlace] = []
    var deleted: [SavedPlace] = []

    func savePlaceIntoDatabase(place: SavedPlace) async throws { if let error { throw error }; saved.append(place) }

    func getPlaceFromDatabase(id: String) async throws -> SavedPlace? { saved.first { $0.id == id } }

    func getPlacesFromDatabase() async throws -> [SavedPlace] { saved }

    func deleteFromDatabase(place: SavedPlace) async throws { deleted.append(place); if let error { throw error } }

    func clearAllFromDatabase() async throws { saved = [] }
}
