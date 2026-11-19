//
//  SettingsViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import CloudKit
import Combine
import CoreLocation
import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    private(set) var isICloudAvailable = false
    private(set) var isUpdatingSync = false
    private(set) var iCloudSyncEnabled = false
    private(set) var syncError: String?
    private(set) var tempScale: TempScale = .fahrenheit {
        didSet { UserDefaults.standard.set(tempScale.rawValue, forKey: UserDefaultKeys.tempScale.rawValue) }
    }

    private func refreshPreferences() {
        let defaults = UserDefaults.standard

        if let value = defaults.string(forKey: UserDefaultKeys.tempScale.rawValue),
            let scale = TempScale(rawValue: value), scale != tempScale
        {
            tempScale = scale
        }

        iCloudSyncEnabled = defaults.bool(forKey: UserDefaultKeys.iCloudSyncEnabled.rawValue)
    }

    private let persistence: PersistenceController?
    private let locationManager: LocationManager?
    private let settingsManager: SettingsManager?
    @ObservationIgnored private var subscriptions = Set<AnyCancellable>()

    // Mirrored from ObservableObject dependencies so observation tracks them.
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private var accountChangeError: Error?

    var displayedSyncError: String? { syncError ?? accountChangeError?.localizedDescription }
    var locationStatusLabel: String {
        switch authorizationStatus {
        case .notDetermined: return Strings.locationNotRequested.rawValue
        case .denied: return Strings.locationDenied.rawValue
        case .restricted: return Strings.locationRestricted.rawValue
        case .authorizedAlways, .authorizedWhenInUse: return Strings.locationEnabled.rawValue
        @unknown default: return Strings.locationUnknown.rawValue
        }
    }

    func manageLocationAccess() {
        guard let locationManager else { return }

        settingsManager?.manageLocationAccess(locationManager: locationManager)
    }

    private let iCloudManager: any ICloudManaging

    init(
        iCloudManager: any ICloudManaging,
        persistence: PersistenceController? = nil,
        locationManager: LocationManager? = nil,
        settingsManager: SettingsManager? = nil
    ) {
        self.iCloudManager = iCloudManager
        self.persistence = persistence
        self.locationManager = locationManager
        self.settingsManager = settingsManager
        refreshPreferences()
        addSubscriptions()
    }

    private func addSubscriptions() {
        locationManager?.$authorizationStatus
            .sink { [weak self] status in self?.authorizationStatus = status }
            .store(in: &subscriptions)

        persistence?.$accountChangeError
            .sink { [weak self] error in self?.accountChangeError = error }
            .store(in: &subscriptions)

        NotificationCenter
            .default
            .publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.refreshPreferences() }
            .store(in: &subscriptions)

        NotificationCenter
            .default
            .publisher(for: .CKAccountChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.refreshICloudAvailability()
                }
            }
            .store(in: &subscriptions)
    }

    func setSyncEnabled(_ enabled: Bool) async {
        guard !isUpdatingSync, !enabled || isICloudAvailable else { return }

        isUpdatingSync = true
        syncError = nil

        defer {
            isUpdatingSync = false
        }

        do {
            try await iCloudManager.setEnabled(enabled)
            refreshPreferences()
        } catch {
            syncError = error.localizedDescription
        }
    }

    func refreshICloudAvailability() async {
        isICloudAvailable = false

        do {
            isICloudAvailable = try await iCloudManager.isAvailable()
        } catch {
            isICloudAvailable = false
        }
    }

    func selectTempScale(_ scale: TempScale) {
        tempScale = scale
    }
}

// MARK: Test hooks

#if DEBUG
extension SettingsViewModel {
    /// Exposes private state to unit tests without widening its access level.
    @MainActor
    struct TestHooks {
        fileprivate let target: SettingsViewModel

        var accountChangeError: Error? { target.accountChangeError }
        var subscriptionCount: Int { target.subscriptions.count }
    }

    var testHooks: TestHooks { TestHooks(target: self) }
}
#endif
