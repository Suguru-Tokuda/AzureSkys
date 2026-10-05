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

    func isAvailable() async throws -> Bool {
        let status = try await CKContainer.default().accountStatus()
        return status == .available
    }

    func setEnabled(_ enabled: Bool) async throws {
        try await persistence.setSyncEnabled(enabled)

        defaults.set(enabled, forKey: UserDefaultKeys.iCloudSyncEnabled.rawValue)
    }
}
