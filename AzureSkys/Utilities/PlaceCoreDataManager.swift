//
//  PlaceCoreDataManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import CoreData

protocol PlaceCoreDataActions {
    func savePlaceIntoDatabase(place: GooglePlaceDetails) async throws
    func getPlaceFromDatabase(id: String) async throws -> GooglePlaceDetails?
    func getPlacesFromDatabase() async throws -> [GooglePlaceDetails]
    func deleteFromDatabase(place: GooglePlaceDetails) async throws
    func clearAllFromDatabase() async throws
}

class PlaceCoreDataManager: PlaceCoreDataActions {
    let persistentContainer: NSPersistentContainer

    init(container: NSPersistentContainer) {
        persistentContainer = container
    }

    func savePlaceIntoDatabase(place: GooglePlaceDetails) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", place.id)
            request.fetchLimit = 1
            guard try context.fetch(request).isEmpty else { return }

            let entity = PlaceEntity(context: context)
            entity.id = place.id
            entity.name = place.name
            entity.addressComponents = try JSONEncoder().encode(place.addressComponents)
            entity.latitude = place.geometry.location.latitude
            entity.longitude = place.geometry.location.longitude
            try context.save()
        }
    }

    func getPlacesFromDatabase() async throws -> [GooglePlaceDetails] {
        try await persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            return try context.fetch(request).compactMap { GooglePlaceDetails(from: $0) }
        }
    }

    func getPlaceFromDatabase(id: String) async throws -> GooglePlaceDetails? {
        try await persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            return try context.fetch(request).first.flatMap { GooglePlaceDetails(from: $0) }
        }
    }

    func deleteFromDatabase(place: GooglePlaceDetails) async throws {
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
