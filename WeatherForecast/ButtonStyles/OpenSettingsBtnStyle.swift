//
//  OpenSettingsBtnModifier.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/14/23.
//

import SwiftUI

struct OpenSettingsBtnStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
