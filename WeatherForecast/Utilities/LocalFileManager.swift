//
//  LocalFileManager.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/15/23.
//

import UIKit

protocol LocalFileManaging {
    func saveImage(image: UIImage, name: String) throws
    func getImage(name: String) throws -> UIImage?
}

class LocalFileManager: LocalFileManaging, ObservableObject {
    func saveImage(image: UIImage, name: String) throws {
        guard let data = image.pngData() else {
            throw FileManagerError.data
        }
        
        guard let path: URL = getPath(name: name) else {
            throw FileManagerError.badPath
        }
        
        do {
            try data.write(to: path)
        } catch {
            throw FileManagerError.save
        }
    }
    
    func getImage(name: String) throws -> UIImage? {
        guard let path = getPath(name: name) else {
            throw FileManagerError.badPath
        }
        
        do {
            let data = try Data(contentsOf: path)
            return UIImage(data: data)
        } catch {
            throw FileManagerError.retrieve
        }
    }
    
    func getPath(name: String) -> URL? {
        return FileManager
            .default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appending(path: name)
    }
}
