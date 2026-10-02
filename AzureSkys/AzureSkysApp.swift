//
//  AzureSkysApp.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//

import SwiftUI

@main
struct AzureSkysApp: App {
    @StateObject private var dependencies = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: dependencies)
                .appEnvironment(dependencies)
        }
    }
}
