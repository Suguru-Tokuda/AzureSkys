//
//  CityCoreDataManager.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/7/23.
//

import CoreData

protocol CityCoreDataActions {
    func saveCityIntoDatabase(city: City) async throws
    func getCityFromDatabase(id: Int) async throws -> City?
    func getCitiesFromDatabase() async throws -> [City]
    func deleteFromDatabase(city: City) async throws
    func clearAllFromDatabase() async throws
}

class CityCoreDataManager: CityCoreDataActions {
    func saveCityIntoDatabase(city: City) async throws {
        do {
            let existinCity = try await self.getCityFromDatabase(id: city.id)
            
            if existinCity == nil {
                try await PersistenceController.shared.container.performBackgroundTask { context in
                    let cityEntity = CityEntity(context: context)
                    
                    cityEntity.id = Int64(city.id)
                    cityEntity.name = city.name
                    cityEntity.country = city.country
                    if let timezone = city.timezone {
                        cityEntity.timezone = Int64(timezone)
                    }
                    cityEntity.latitude = city.coordinate.lat
                    cityEntity.longitude = city.coordinate.lon
                    
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
    
    func getCitiesFromDatabase() async throws -> [City] {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        var retVal: [City] = []
        
        try await PersistenceController.shared.container.performBackgroundTask { context in
            let allRecords = try context.fetch(request)
            
            retVal = allRecords.map { entity in
                City(id: Int(entity.id), population: 0, timezone: Int(entity.timezone), coordinate: CityCoordinate(lat: entity.latitude, lon: entity.longitude), name: entity.name ?? "", country: entity.country ?? "", sunrise: 0, sunset: 0)
            }
        }
        
        return retVal
    }

    func getCityFromDatabase(id: Int) async throws -> City? {
        
        var retVal: City?
        
        try await PersistenceController.shared.container.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %d", id as CVarArg)

                let allRecords = try context.fetch(request)
                
                if let entity = allRecords.first {
                    retVal = City(id: Int(entity.id), population: 0, timezone: Int(entity.timezone), coordinate: CityCoordinate(lat: entity.latitude, lon: entity.longitude), name: entity.name ?? "", country: entity.country ?? "", sunrise: 0, sunset: 0)
                }
            }
        }
        
        return retVal
    }
    
    func deleteFromDatabase(city: City) async throws {
        do {
            try await PersistenceController.shared.container.performBackgroundTask { context in
                let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %d", city.id as CVarArg)

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
            let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
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
