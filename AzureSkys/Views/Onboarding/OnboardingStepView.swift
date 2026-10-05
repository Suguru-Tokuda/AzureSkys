//
//  OnboardingStepView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import SwiftUI

struct OnboardingStepView<Content: View>: View {
    let iconImageName: String
    let titleLabel: String
    let description: String
    let contentView: Content
    let enableButtonDesc: String
    let disableButtonDesc: String
    let isEnableButtonEnabled: Bool
    let shouldShowEnableButton: Bool
    let shouldShowDisableButton: Bool
    let usesCompactLayout: Bool
    let onButtonClick: ((Bool) -> Void)?
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 36

    init(
        iconImageName: String,
        titleLabel: String,
        description: String,
        enableButtonDesc: String,
        disableButtonDesc: String,
        isEnableButtonEnabled: Bool = true,
        usesCompactLayout: Bool = false,
        onButtonClick: ((Bool) -> Void)? = nil,
        shouldShowEnableButton: Bool = true,
        shouldShowDisableButton: Bool = true,
        @ViewBuilder contentView: () -> Content
    ) {
        self.iconImageName = iconImageName
        self.titleLabel = titleLabel
        self.description = description
        self.enableButtonDesc = enableButtonDesc
        self.disableButtonDesc = disableButtonDesc
        self.isEnableButtonEnabled = isEnableButtonEnabled
        self.usesCompactLayout = usesCompactLayout
        self.onButtonClick = onButtonClick
        self.shouldShowEnableButton = shouldShowEnableButton
        self.shouldShowDisableButton = shouldShowDisableButton
        self.contentView = contentView()
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: usesCompactLayout ? 8 : 20)

                    OnboardingIconView(imageName: iconImageName, diameter: usesCompactLayout ? 110 : 180)

                    Text(titleLabel)
                        .font(.system(size: usesCompactLayout ? titleSize * 0.83 : titleSize, weight: .bold))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, usesCompactLayout ? 14 : 28)

                    Text(description)
                        .font(usesCompactLayout ? .body : .title3)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.top, usesCompactLayout ? 12 : 20)

                    contentView
                        .padding(.horizontal, 8)
                        .padding(.top, usesCompactLayout ? 16 : 36)

                    Spacer(minLength: usesCompactLayout ? 16 : 32)

                    if shouldShowEnableButton {
                        Button(enableButtonDesc) {
                            onButtonClick?(true)
                        }
                        .buttonStyle(OnboardingButtonStyle())
                        .disabled(!isEnableButtonEnabled)
                        .opacity(isEnableButtonEnabled ? 1 : 0.45)
                    }

                    if shouldShowDisableButton {
                        Button(disableButtonDesc) {
                            onButtonClick?(false)
                        }
                        .font(.body)
                        .buttonStyle(.plain)
                        .frame(minHeight: 44)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

//#Preview {
//    OnboardingStepView()
//}
