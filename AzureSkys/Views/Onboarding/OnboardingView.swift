//
//  OnboardingView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var vm: OnboardingViewModel

    @EnvironmentObject private var coordinator: OnboardingCoordiantor

    init(dependencies: AppDependencies) {
        _vm = StateObject(wrappedValue: dependencies.makeOnboardingViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch coordinator.currentStep {
                case .location:
                    OnboardingStepView(
                        iconImageName: SystemImages.locationFill.rawValue,
                        titleLabel: Strings.weatherWhereYouAre.rawValue,
                        description: Strings.locationAccessDescription.rawValue,
                        enableButtonDesc: Strings.allowLocation.rawValue,
                        disableButtonDesc: Strings.chooseCitiesInstead.rawValue
                    ) { enabled in
                        if enabled {
                            vm.enableLocation()
                        } else {
                            coordinator.nextStep()
                        }
                    } contentView: {
                        OnboardingLocationCard()
                    }
                    .padding(.horizontal, 24)

                case .cloudSync:
                    OnboardingStepView(
                        iconImageName: SystemImages.iCloudSyncFill.rawValue,
                        titleLabel: Strings.yourPlacesEverywhere.rawValue,
                        description: Strings.iCloudSyncDescription.rawValue,
                        enableButtonDesc: Strings.enableICloudSync.rawValue,
                        disableButtonDesc: Strings.notNow.rawValue,
                        isEnableButtonEnabled: vm.isICloudAvailable && !vm.isCheckingICloud,
                        usesCompactLayout: true
                    ) { enabled in
                        if enabled {
                            Task {
                                if await vm.enableCloudSync() {
                                    coordinator.nextStep()
                                }
                            }
                        } else {
                            coordinator.nextStep()
                        }
                    } contentView: {
                        if vm.isCheckingICloud {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity, minHeight: 80)
                        } else if vm.isICloudAvailable {
                            OnboardingSyncCard()
                        } else {
                            OnboardingICloudInstructionsView(errorMessage: vm.iCloudCheckError)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 8) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    Circle()
                        .fill(
                            coordinator.currentStep == step
                                ? Color.white
                                : Color.white.opacity(0.35)
                        )
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                coordinator.currentStep == .location ? Strings.step1Of2.rawValue : Strings.step2Of2.rawValue
            )
        }
        .onChange(of: vm.didResolveLocationRequest) { _, resolved in
            if resolved, coordinator.currentStep == .location {
                coordinator.nextStep()
            }
        }
        .task(id: coordinator.currentStep) {
            guard coordinator.currentStep == .cloudSync else { return }

            await vm.checkICloudAvailability()
        }

        .onChange(of: scenePhase) { _, phase in
            if phase == .active, coordinator.currentStep == .cloudSync {
                Task {
                    await vm.checkICloudAvailability()
                }
            }
        }
        .background {
            GeometryReader { geometry in
                Image(ImageAssets.onboardingSky.rawValue)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()

    OnboardingFlow(dependencies: dependencies, onFinished: {})
}

#Preview("iCloud onboarding") {
    let dependencies = AppDependencies.preview()

    OnboardingFlow(dependencies: dependencies, initialStep: .cloudSync, onFinished: {})
}
