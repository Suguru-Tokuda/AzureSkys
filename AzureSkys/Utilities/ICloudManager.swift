//
//  ICloudManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import CloudKit

protocol ICloudManaging {
    func isAvailable() async throws -> Bool
    func setEnabled(_ enabled: Bool) async throws
}

final class ICloudManager: ICloudManaging {
    private let persistence: PersistenceController
    private let defaults: UserDefaults

    init(
        persistence: PersistenceController,
        defaults: UserDefaults = .standard
    ) {
        self.persistence = persistence
        self.defaults = defaults
    }

    // UserDefaults is removed on uninstall. An existing sync zone is durable
    // evidence that this account previously enabled location sync.
    func restoreSyncAfterReinstall(
        hasCloudLocations: () async throws -> Bool = {
            let database = CKContainer(identifier: "iCloud.com.stokuda.weather").privateCloudDatabase
            let zones = try await database.allRecordZones()

            return zones.contains {
                $0.zoneID == LocationCloudRecord.zoneID || $0.zoneID == LocationCloudRecord.legacyZoneID
            }
        }
    ) async throws {
        guard defaults.object(forKey: UserDefaultKeys.iCloudSyncEnabled.rawValue) == nil else { return }

        guard try await hasCloudLocations() else { return }
        // A user may change the setting while cloud discovery is in flight.

        guard defaults.object(forKey: UserDefaultKeys.iCloudSyncEnabled.rawValue) == nil else { return }

        try await setEnabled(true)
    }

    func isAvailable() async throws -> Bool {
        let status = try await CKContainer.default().accountStatus()

        return status == .available
    }

    func setEnabled(_ enabled: Bool) async throws {
        try await persistence.setSyncEnabled(enabled)

        defaults.set(enabled, forKey: UserDefaultKeys.iCloudSyncEnabled.rawValue)
    }
}
