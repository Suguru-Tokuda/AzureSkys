//
//  OnboardingButtonStyle.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import SwiftUI

struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(.white, in: Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(
                .easeOut(duration: 0.15),
                value: configuration.isPressed
            )
    }
}
