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
final class SettingsViewModel: ObservableObject {
    @Published private(set) var isICloudAvailable = false

    @Published private(set) var isUpdatingSync = false
    @Published var syncError: String?

    @Published var tempScale: TempScale = .fahrenheit {
        didSet { UserDefaults.standard.set(tempScale.rawValue, forKey: UserDefaultKeys.tempScale.rawValue) }
    }
    @Published private(set) var iCloudSyncEnabled = false

    private func refreshPreferences() {
        let defaults = UserDefaults.standard
        if let value = defaults.string(forKey: UserDefaultKeys.tempScale.rawValue),
           let scale = TempScale(rawValue: value), scale != tempScale {
            tempScale = scale
        }
        iCloudSyncEnabled = defaults.bool(forKey: UserDefaultKeys.iCloudSyncEnabled.rawValue)
    }
    private let persistence: PersistenceController?
    private let locationManager: LocationManager?
    private let settingsManager: SettingsManager?
    private var subscriptions = Set<AnyCancellable>()

    var pendingUploadCount: Int { persistence?.pendingUploadCount ?? 0 }
    var displayedSyncError: String? { syncError ?? persistence?.accountChangeError?.localizedDescription }
    var authorizationStatus: CLAuthorizationStatus { locationManager?.authorizationStatus ?? .notDetermined }
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

    init(iCloudManager: any ICloudManaging, persistence: PersistenceController? = nil,
         locationManager: LocationManager? = nil, settingsManager: SettingsManager? = nil) {
        self.iCloudManager = iCloudManager
        self.persistence = persistence
        self.locationManager = locationManager
        self.settingsManager = settingsManager
        refreshPreferences()
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.refreshPreferences() }
            .store(in: &subscriptions)
        persistence?.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &subscriptions)
        locationManager?.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &subscriptions)
        NotificationCenter.default.publisher(for: .CKAccountChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.refreshICloudAvailability() }
            }
            .store(in: &subscriptions)
    }

    func setSyncEnabled(_ enabled: Bool) async {
        guard !isUpdatingSync, !enabled || isICloudAvailable else { return }
        isUpdatingSync = true
        syncError = nil
        defer { isUpdatingSync = false }
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
}
