//
//  AzureSkysApp.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//

import SwiftUI

@main
struct AzureSkysApp: App {
    @StateObject private var dependencies: AppDependencies

    init() {
        #if DEBUG
        let isUITesting = ProcessInfo.processInfo.arguments.contains(LaunchArguments.uiTestingArgument)
        let isUnitTesting = ProcessInfo.processInfo.environment[LaunchArguments.testConfigurationEnvironmentKey] != nil
        _dependencies = StateObject(wrappedValue: isUITesting ? .uiTesting() : (isUnitTesting ? .preview() : .live()))
        #else
        _dependencies = StateObject(wrappedValue: .live())
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: dependencies)
                .appEnvironment(dependencies)
        }
    }
}
