//
//  OnboardingIconView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import SwiftUI

struct OnboardingIconView: View {
    var imageName: String
    var diameter: CGFloat = 180

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .light)
                .opacity(0.35)
                .overlay {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.12),
                                    .white.opacity(0.02),
                                    .white.opacity(0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.06), radius: 16, y: 8)

            Image(systemName: imageName)
                .font(.system(size: diameter * 0.367, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: diameter, height: diameter)
        .accessibilityHidden(true)
    }
}

#Preview {
    OnboardingIconView(imageName: SystemImages.locationFill.rawValue)
    OnboardingIconView(imageName: SystemImages.iCloudSyncFill.rawValue)
}
