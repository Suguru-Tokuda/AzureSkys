//
//  PersistenceError.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import Foundation

enum PersistenceError: Error {
    case missingStoreDescription
    case missingStoreURL
}
