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

class PlaceCoreDataManager: PlaceCoreDataActions {
    let persistentContainer: NSPersistentContainer

    init(container: NSPersistentContainer) {
        persistentContainer = container
    }

    func savePlaceIntoDatabase(place: SavedPlace) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", place.id)
            request.fetchLimit = 1
            guard try context.fetch(request).isEmpty else { return }

            let entity = PlaceEntity(context: context)
            entity.id = place.id
            entity.name = place.name
            entity.formattedAddress = place.formattedAddress
            entity.addressComponents = try JSONEncoder().encode(place.addressComponents)
            entity.latitude = place.latitude
            entity.longitude = place.longitude
            try context.save()
        }
    }

    func getPlacesFromDatabase() async throws -> [SavedPlace] {
        try await persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            return try context.fetch(request).compactMap { SavedPlace(from: $0) }
        }
    }

    func getPlaceFromDatabase(id: String) async throws -> SavedPlace? {
        try await persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            return try context.fetch(request).first.flatMap { SavedPlace(from: $0) }
        }
    }

    func deleteFromDatabase(place: SavedPlace) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", place.id)
            let records = try context.fetch(request)
            records.forEach { context.delete($0) }
            try context.save()
        }
    }

    func clearAllFromDatabase() async throws {
        try await persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            let records = try context.fetch(request)
            records.forEach { context.delete($0) }
            try context.save()
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
