//
//  AzureSkysApp.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//

import SwiftUI

@main
struct AzureSkysApp: App {
    @StateObject var locationManager: LocationManager
    @StateObject var mainCoordinator: MainCoordinator
    @StateObject var fileManager: LocalFileManager
    let persistenceController = PersistenceController.shared
    
    init() {
        _locationManager = StateObject(wrappedValue: LocationManager())
        _mainCoordinator = StateObject(wrappedValue: MainCoordinator())
        _fileManager = StateObject(wrappedValue: LocalFileManager())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(mainCoordinator)
                .environmentObject(fileManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
