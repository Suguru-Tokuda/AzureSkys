import SwiftUI

struct OnboardingFlow: View {
    @StateObject private var coordinator: OnboardingCoordiantor

    init(dependencies: AppDependencies,
         initialStep: OnboardingStep = .location,
         onFinished: @escaping () -> Void) {
        _coordinator = StateObject(wrappedValue: OnboardingCoordiantor(
            dependencies: dependencies,
            initialStep: initialStep,
            onFinished: onFinished
        ))
    }

    var body: some View {
        coordinator.destination()
    }
}
