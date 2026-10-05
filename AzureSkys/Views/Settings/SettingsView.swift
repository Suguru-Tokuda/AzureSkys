//
//  SettingsView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import SwiftUI
import CoreLocation

struct SettingsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.dismiss) private var dismiss
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(Strings.settings.rawValue)
                        .font(.largeTitle.bold())
                    Text(Strings.settingsSubtitle.rawValue)
                        .font(.title3)
                        .foregroundStyle(secondaryColor)
                }
                .padding(.top, 12)
                .padding(.bottom, 12)

                locationCard
                preferencesCard
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .background {
            BackGroundView()
        }
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: SystemImages.chevronLeft.rawValue)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .modifier(WeatherPanelModifier(cornerRadius: 22))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Strings.back.rawValue)
            }
        }
        .task {
            await vm.refreshICloudAvailability()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
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
        case .notDetermined: return Strings.locationNotRequested.rawValue
        case .denied: return Strings.locationDenied.rawValue
        case .restricted: return Strings.locationRestricted.rawValue
        case .authorizedAlways, .authorizedWhenInUse: return Strings.locationEnabled.rawValue
        @unknown default: return Strings.locationUnknown.rawValue
        }
    }

    private var secondaryColor: Color {
        Color(red: 0.68, green: 0.79, blue: 0.95)
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .tracking(1.2)
            .foregroundStyle(secondaryColor)
            .accessibilityAddTraits(.isHeader)
    }

    private func settingIcon(_ image: SystemImages) -> some View {
        Image(systemName: image.rawValue)
            .font(.system(size: 25, weight: .medium))
            .foregroundStyle(Color(red: 0.43, green: 0.76, blue: 1))
            .frame(width: 48, height: 48)
            .modifier(WeatherPanelModifier(cornerRadius: 15))
            .accessibilityHidden(true)
    }

    private func settingHeading(_ title: String, subtitle: String, icon: SystemImages) -> some View {
        HStack(spacing: 16) {
            settingIcon(icon)
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(secondaryColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeading(Strings.settingsYourLocation.rawValue)
            HStack(alignment: .center, spacing: 12) {
                settingHeading(Strings.locationAccess.rawValue,
                               subtitle: Strings.settingsLocationDescription.rawValue,
                               icon: .locationFill)
                Spacer(minLength: 0)
                Text(locationStatusLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(secondaryColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.blue.opacity(0.2), in: Capsule())
                    .overlay { Capsule().strokeBorder(.white.opacity(0.2)) }
            }

            Divider().overlay(.white.opacity(0.12))

            Button {
                settingsManager.manageLocationAccess(locationManager: locationManager)
            } label: {
                HStack {
                    Text(locationManager.authorizationStatus == .notDetermined
                         ? Strings.enableLocation.rawValue
                         : Strings.manageLocation.rawValue)
                    Spacer()
                    Image(systemName: SystemImages.chevronRight.rawValue)
                        .foregroundStyle(secondaryColor)
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(locationManager.authorizationStatus == .restricted)

            if locationManager.authorizationStatus == .restricted {
                Text(Strings.locationRestrictedDescription.rawValue)
                    .font(.footnote)
                    .foregroundStyle(secondaryColor)
            }
        }
        .padding(20)
        .modifier(WeatherPanelModifier())
    }

    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeading(Strings.settingsPreferences.rawValue)
            temperatureRow
            Divider().overlay(.white.opacity(0.12))
            syncRow
        }
        .padding(20)
        .modifier(WeatherPanelModifier())
    }

    private var temperatureRow: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    temperatureHeading
                    temperatureSelector
                }
            } else {
                HStack(spacing: 12) {
                    temperatureHeading
                    Spacer(minLength: 0)
                    temperatureSelector.frame(width: 128)
                }
            }
        }
    }

    private var temperatureHeading: some View {
        HStack(spacing: 16) {
            settingIcon(.thermometerMedium)
            Text(Strings.temperature.rawValue)
                .font(.headline)
        }
    }

    private var temperatureSelector: some View {
        HStack(spacing: 4) {
            ForEach(TempScale.allCases) { scale in
                Button {
                    tempScale = scale
                } label: {
                    Text(scale.shortName)
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background {
                        if tempScale == scale {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.opacity(0.55))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(.white.opacity(0.3))
                                }
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(scale.displayName)
                .accessibilityAddTraits(tempScale == scale ? .isSelected : [])
            }
        }
        .padding(4)
        .background(.black.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
        .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.25)) }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Strings.temperatureUnit.rawValue)
    }


    private var syncRow: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle(isOn: Binding(
                get: { iCloudSyncEnabled && vm.isICloudAvailable },
                set: { enabled in
                    Task { await vm.setSyncEnabled(enabled) }
                }
            )) {
                settingHeading(Strings.iCloudSync.rawValue,
                               subtitle: Strings.settingsSyncDescription.rawValue,
                               icon: .iCloudFill)
            }
            .tint(.green)
            .disabled(vm.isUpdatingSync || (!vm.isICloudAvailable && !iCloudSyncEnabled))

            if vm.isUpdatingSync {
                ProgressView().accessibilityLabel(Strings.loading.rawValue)
            }
            if let error = vm.syncError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(secondaryColor)
            } else if !vm.isICloudAvailable {
                Text(Strings.iCloudUnavailableDescription.rawValue)
                    .font(.footnote)
                    .foregroundStyle(secondaryColor)
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
