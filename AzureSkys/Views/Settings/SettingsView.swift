//
//  SettingsView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(UserDefaultKeys.tempScale.rawValue)
    private var tempScale: TempScale = .fahrenheit

    @AppStorage(UserDefaultKeys.iCloudSyncEnabled.rawValue)
    private var iCloudSyncEnabled = false

    @StateObject private var vm: SettingsViewModel

    init(dependencies: AppDependencies) {
        _vm = StateObject(
            wrappedValue: dependencies.makeSettingsViewModel()
        )
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text(Strings.temperature.rawValue)
                    Spacer()
                    Text(tempScale.shortName)
                        .foregroundStyle(.secondary)
                    Menu {
                        Picker(Strings.temperature.rawValue, selection: $tempScale) {
                            ForEach(TempScale.allCases) { scale in
                                Text(scale.shortName)
                                    .tag(scale)
                            }
                        }
                        .pickerStyle(.inline)
                    } label: {
                        Image(systemName: SystemImages.ellipsisCircle.rawValue)
                    }
                    .accessibilityLabel(Strings.temperatureUnit.rawValue)
                    .accessibilityValue(tempScale.displayName)
                }

                Toggle(
                    Strings.iCloudSync.rawValue,
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
                    Text(Strings.iCloudUnavailableDescription.rawValue)
                }
            }
        }
        .navigationTitle(Strings.settings.rawValue)
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
