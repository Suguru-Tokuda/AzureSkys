//
//  SettingsManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/20/23.
//

import SwiftUI

class SettingsManager {
    private let canOpen: (URL) -> Bool
    private let open: (URL) -> Void

    init(canOpen: @escaping (URL) -> Bool = { UIApplication.shared.canOpenURL($0) },
         open: @escaping (URL) -> Void = { UIApplication.shared.open($0) }) {
        self.canOpen = canOpen
        self.open = open
    }

    func navigateToSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              canOpen(settingsURL) else { return }
        open(settingsURL)
    }
}
