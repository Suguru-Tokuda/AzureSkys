import SwiftUI

enum OnboardingStep: CaseIterable, Hashable {
    case location
    case cloudSync
}

@MainActor
final class OnboardingCoordiantor: ObservableObject {
    @Published private(set) var currentStep: OnboardingStep

    private let dependencies: AppDependencies
    private let onFinished: () -> Void
    private var hasFinished = false

    init(
        dependencies: AppDependencies,
        initialStep: OnboardingStep = .location,
        onFinished: @escaping () -> Void
    ) {
        self.dependencies = dependencies
        self.currentStep = initialStep
        self.onFinished = onFinished
    }

    func nextStep() {
        guard !hasFinished else { return }

        switch currentStep {
        case .location:
            currentStep = .cloudSync

        case .cloudSync:
            hasFinished = true
            onFinished()
        }
    }

    func destination() -> some View {
        OnboardingView(dependencies: dependencies)
            .environmentObject(self)
    }
}
