//
//  SettingsManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/20/23.
//

import SwiftUI

class SettingsManager: NSObject {
    @AppStorage(UserDefaultKeys.tempScale.rawValue) var tempScale = TempScale.fahrenheit.rawValue
    
    override init() {
        super.init()
        self.addObserver()
    }
    
    // You can add observer for settings change for the key.
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.tempScaleChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    @objc func tempScaleChanged() {
        if let _ = UserDefaults.standard.string(forKey: UserDefaultKeys.tempScale.rawValue) {
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func navigateToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { _ in }
        }
    }
}
