//
//  SettingsManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/20/23.
//

import SwiftUI

class SettingsManager {
    func navigateToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { _ in }
        }
    }
}
