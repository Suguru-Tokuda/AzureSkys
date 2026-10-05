//
//  SettingsViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import CloudKit
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var isICloudAvailable = false

    @Published private(set) var isUpdatingSync = false
    @Published var syncError: String?

    private let iCloudManager: any ICloudManaging

    init(iCloudManager: any ICloudManaging) {
        self.iCloudManager = iCloudManager
    }

    func setSyncEnabled(_ enabled: Bool) async {
        guard !isUpdatingSync, !enabled || isICloudAvailable else { return }
        isUpdatingSync = true
        syncError = nil
        defer { isUpdatingSync = false }
        do {
            try await iCloudManager.setEnabled(enabled)
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
