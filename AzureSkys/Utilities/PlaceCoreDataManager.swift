//
//  PlaceCoreDataManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import CoreData

protocol PlaceCoreDataActions {
    func savePlaceIntoDatabase(place: SavedPlace) async throws
    func getPlaceFromDatabase(id: String) async throws -> SavedPlace?
    func getPlacesFromDatabase() async throws -> [SavedPlace]
    func deleteFromDatabase(place: SavedPlace) async throws
    func clearAllFromDatabase() async throws
}

@MainActor
class PlaceCoreDataManager: PlaceCoreDataActions {
    private let persistence: PersistenceController

    init(persistence: PersistenceController) {
        self.persistence = persistence
    }

    func savePlaceIntoDatabase(place: SavedPlace) async throws {
        try await persistence.performLocationChange { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", place.id)
            request.fetchLimit = 1
            guard try context.fetch(request).isEmpty else { return }

            let entity = PlaceEntity(entity: NSEntityDescription.entity(forEntityName: PlaceCoreDataManagerConstants.placeEntity, in: context)!, insertInto: context)
            entity.id = place.id
            entity.name = place.name
            entity.formattedAddress = place.formattedAddress
            entity.addressComponents = try JSONEncoder().encode(place.addressComponents)
            entity.latitude = place.latitude
            entity.longitude = place.longitude
        }
    }

    func getPlacesFromDatabase() async throws -> [SavedPlace] {
        try await persistence.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            return try context.fetch(request).compactMap { SavedPlace(from: $0) }
        }
    }

    func getPlaceFromDatabase(id: String) async throws -> SavedPlace? {
        try await persistence.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            return try context.fetch(request).first.flatMap { SavedPlace(from: $0) }
        }
    }

    func deleteFromDatabase(place: SavedPlace) async throws {
        try await persistence.performLocationChange { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", place.id)
            let records = try context.fetch(request)
            records.forEach { context.delete($0) }
        }
    }

    func clearAllFromDatabase() async throws {
        try await persistence.performLocationChange { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            let records = try context.fetch(request)
            records.forEach { context.delete($0) }
        }
    }
}

extension SavedPlace {
    init?(from entity: PlaceEntity) {
        guard let id = entity.id else { return nil }
        let components = entity.addressComponents.flatMap {
            try? JSONDecoder().decode([PlaceAddressComponent].self, from: $0)
        } ?? []
        self.init(id: id, name: entity.name ?? "",
                  formattedAddress: entity.formattedAddress ?? "",
                  latitude: entity.latitude, longitude: entity.longitude,
                  addressComponents: components)
    }
}

private enum PlaceCoreDataManagerConstants {
    static let placeEntity = "PlaceEntity"
}
