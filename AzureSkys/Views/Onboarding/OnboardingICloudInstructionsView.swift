//
//  OnboardingICloudInstructionsView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/1/26.
//

import SwiftUI

struct OnboardingICloudInstructionsView: View {
    var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(OnboardingStrings.onboardingICloudSetupTitle)
                .font(.headline)

            if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
            }

            instruction(1, text: OnboardingStrings.onboardingICloudSetupStepOne)
            instruction(2, text: OnboardingStrings.onboardingICloudSetupStepTwo)
            instruction(3, text: OnboardingStrings.onboardingICloudSetupStepThree)

            Text(OnboardingStrings.onboardingICloudSetupReturn)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))

        }
        .padding(16)
        .modifier(OnboardingWeatherCardStyle())
    }

    private func instruction(_ number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number.formatted())
                .font(.caption.weight(.bold))
                .frame(width: 24, height: 24)
                .background(.white.opacity(0.18), in: Circle())
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OnboardingICloudInstructionsView()
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.gradient)
}
