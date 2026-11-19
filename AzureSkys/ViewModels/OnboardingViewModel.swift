//
//  OnboardingViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import Combine
import SwiftUI

@MainActor
@Observable
final class OnboardingViewModel {
    private(set) var didResolveLocationRequest = false
    private(set) var isICloudAvailable = false
    private(set) var isCheckingICloud = false
    private(set) var iCloudCheckError: String?
    
    @ObservationIgnored private var isRequestingLocation = false
    @ObservationIgnored private var subscriptions = Set<AnyCancellable>()

    private let locationManager: LocationManager
    private let iCloudManager: ICloudManaging

    init(locationManager: LocationManager, iCloudManager: ICloudManaging) {
        self.locationManager = locationManager
        self.iCloudManager = iCloudManager
        addSubscriptions()
    }

    func enableLocation() {
        guard !isRequestingLocation else { return }

        didResolveLocationRequest = false

        if locationManager.locationManager.authorizationStatus != .notDetermined {
            didResolveLocationRequest = true

            return
        }

        isRequestingLocation = true
        locationManager.requestAuthorization()
    }

    func enableCloudSync() async -> Bool {
        guard isICloudAvailable, !isCheckingICloud else {
            return false
        }

        do {
            try await iCloudManager.setEnabled(true)

            return true
        } catch {
            iCloudCheckError = error.localizedDescription

            return false
        }
    }

    func checkICloudAvailability() async {
        guard !isCheckingICloud else { return }

        isCheckingICloud = true
        isICloudAvailable = false
        iCloudCheckError = nil

        defer {
            isCheckingICloud = false
        }

        do {
            isICloudAvailable = try await iCloudManager.isAvailable()
        } catch {
            iCloudCheckError = Strings.iCloudCheckError.rawValue
        }
    }

    private func addSubscriptions() {
        locationManager
            .$locationAuthorized
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthorized in
                guard let self, self.isRequestingLocation, isAuthorized != nil else { return }

                isRequestingLocation = false
                didResolveLocationRequest = true
            }
            .store(in: &subscriptions)
    }
}

// MARK: Test hooks

#if DEBUG
extension OnboardingViewModel {
    /// Exposes private state to unit tests without widening its access level.
    @MainActor
    struct TestHooks {
        fileprivate let target: OnboardingViewModel

        var isRequestingLocation: Bool { target.isRequestingLocation }
        var subscriptionCount: Int { target.subscriptions.count }
    }

    var testHooks: TestHooks { TestHooks(target: self) }
}
#endif
