//
//  PlaceCoreDataManager.swift
//  WeatherForecast
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
    func savePlaceIntoDatabase(place: GooglePlaceDetails) async throws {
        do {
            let existinPlace = try await self.getPlaceFromDatabase(id: place.id)
            
            if existinPlace == nil {
                try await PersistenceController.shared.container.performBackgroundTask { context in
                    let placeEntity = PlaceEntity(context: context)
                    
                    placeEntity.id = place.id
                    placeEntity.name = place.name
                    placeEntity.addressComponents = try? JSONEncoder().encode(place.addressComponents)
                    placeEntity.latitude = place.geometry.location.latitude
                    placeEntity.longitude = place.geometry.location.longitude
                                        
                    do {
                        try self.save(context: context)
                    } catch {
                        throw error
                    }
                }
            }
        } catch {
            throw error
        }
    }
    
    func getPlacesFromDatabase() async throws -> [GooglePlaceDetails] {
        let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
        var retVal: [GooglePlaceDetails] = []
        
        try await PersistenceController.shared.container.performBackgroundTask { context in
            let allRecords = try context.fetch(request)
            
            retVal = allRecords.map { entity in
                GooglePlaceDetails(from: entity)
            }
            .compactMap { $0 }
        }
        
        return retVal
    }

    func getPlaceFromDatabase(id: String) async throws -> GooglePlaceDetails? {
        
        var retVal: GooglePlaceDetails?
        
        try await PersistenceController.shared.container.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                let allRecords = try context.fetch(request)
                
                if let entity = allRecords.first,
                   let place = GooglePlaceDetails(from: entity) {
                    retVal = place
                }
            }
        }
        
        return retVal
    }
    
    func deleteFromDatabase(place: GooglePlaceDetails) async throws {
        do {
            try await PersistenceController.shared.container.performBackgroundTask { context in
                let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", place.id as CVarArg)

                let allRecords = try context.fetch(request)
                allRecords.forEach { context.delete($0) }
                
                try self.save(context: context)
            }
        } catch {
            throw error
        }
    }
    
    func clearAllFromDatabase() async throws {
        try await PersistenceController.shared.container.performBackgroundTask { context in
            let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
            let allRecords = try context.fetch(request)
            
            allRecords.forEach { context.delete($0) }
            
            try self.save(context: context)
        }
    }
    
    func save(context: NSManagedObjectContext) throws {
        do {
            try context.save()
        } catch {
            throw error
        }
    }
}
