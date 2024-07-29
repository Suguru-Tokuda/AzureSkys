//
//  UIApplication.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/8/23.
//

import SwiftUI

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
