//
//  SettingsView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import SwiftUI
import CoreLocation

struct SettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(UserDefaultKeys.tempScale.rawValue)
    private var tempScale: TempScale = .fahrenheit

    @AppStorage(UserDefaultKeys.iCloudSyncEnabled.rawValue)
    private var iCloudSyncEnabled = false

    @EnvironmentObject private var locationManager: LocationManager
    private let settingsManager: SettingsManager

    @StateObject private var vm: SettingsViewModel

    init(dependencies: AppDependencies) {
        settingsManager = dependencies.settingsManager
        _vm = StateObject(
            wrappedValue: dependencies.makeSettingsViewModel()
        )
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text(SettingsStrings.locationAccess)
                    Spacer()
                    Text(locationStatusLabel)
                        .foregroundStyle(.secondary)
                }
                Button(locationManager.authorizationStatus == .notDetermined
                       ? SettingsStrings.enableLocation
                       : SettingsStrings.manageLocation) {
                    settingsManager.manageLocationAccess(locationManager: locationManager)
                }
                .disabled(locationManager.authorizationStatus == .restricted)
            } footer: {
                if locationManager.authorizationStatus == .restricted {
                    Text(SettingsStrings.locationRestrictedDescription)
                }
            }

            Section {
                HStack {
                    Text(SettingsStrings.temperature)
                    Spacer()
                    Text(tempScale.shortName)
                        .foregroundStyle(.secondary)
                    Menu {
                        Picker(SettingsStrings.temperature, selection: $tempScale) {
                            ForEach(TempScale.allCases) { scale in
                                Text(scale.shortName)
                                    .tag(scale)
                            }
                        }
                        .pickerStyle(.inline)
                    } label: {
                        Image(systemName: SystemImages.ellipsisCircle.rawValue)
                    }
                    .accessibilityLabel(SettingsStrings.temperatureUnit)
                    .accessibilityValue(tempScale.displayName)
                }

                Toggle(
                    SettingsStrings.iCloudSync,
                    isOn: Binding(
                        get: {
                            iCloudSyncEnabled && vm.isICloudAvailable
                        },
                        set: {
                            let enabled = $0
                            Task { await vm.setSyncEnabled(enabled) }
                        }
                    )
                )
                .disabled(vm.isUpdatingSync || (!vm.isICloudAvailable && !iCloudSyncEnabled))
            } footer: {
                if let error = vm.syncError {
                    Text(error)
                } else if !vm.isICloudAvailable {
                    Text(SettingsStrings.iCloudUnavailableDescription)
                }
            }
        }
        .navigationTitle(SettingsStrings.settings)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.refreshICloudAvailability()
        }
        .onChange(of: scenePhase) { _, pahse in
            if pahse == .active {
                Task {
                    await vm.refreshICloudAvailability()
                }
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .CKAccountChanged)
        ) { _ in
            Task {
                await vm.refreshICloudAvailability()
            }
        }
    }

    private var locationStatusLabel: String {
        switch locationManager.authorizationStatus {
        case .notDetermined: return SettingsStrings.locationNotRequested
        case .denied: return SettingsStrings.locationDenied
        case .restricted: return SettingsStrings.locationRestricted
        case .authorizedAlways, .authorizedWhenInUse: return SettingsStrings.locationEnabled
        @unknown default: return SettingsStrings.locationUnknown
        }
    }

    private func temperatureOption(_ scale: TempScale) -> some View {
        HStack {
            Text(scale.displayName)
            Spacer()
            Text(scale.shortName)
            if tempScale == scale {
                Image(systemName: SystemImages.checkmark.rawValue)
            }
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()

    NavigationStack {
        SettingsView(dependencies: dependencies)
    }
    .appEnvironment(dependencies)
}
