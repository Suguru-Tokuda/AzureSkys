//
//  Color.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/11/23.
//

import SwiftUI

extension Color {
    static let skyBlue = LinearGradient(gradient: Gradient(colors: [Color.sky1, Color.sky2]), startPoint: .topLeading, endPoint: .bottomTrailing)
    static let clearNight = LinearGradient(gradient: Gradient(colors: [Color.night1, Color.night2]), startPoint: .topLeading, endPoint: .bottomTrailing)
    static let cloudyDay = LinearGradient(gradient: Gradient(colors: [Color.cloudy1, Color.cloudy2]), startPoint: .topLeading, endPoint: .bottomTrailing)
    static let cloudyNight = LinearGradient(gradient: Gradient(colors: [Color.cloudy3, Color.cloudy4]), startPoint: .topLeading, endPoint: .bottomTrailing)
}
