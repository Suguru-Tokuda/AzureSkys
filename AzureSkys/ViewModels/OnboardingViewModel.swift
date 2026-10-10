//
//  OnboardingViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import Combine
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published private(set) var didResolveLocationRequest = false
    private var isRequestingLocation = false

    @Published private(set) var isICloudAvailable = false
    @Published private(set) var isCheckingICloud = false
    @Published var iCloudCheckError: String?

    private var subscriptions = Set<AnyCancellable>()

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

                self.isRequestingLocation = false
                self.didResolveLocationRequest = true
            }

            .store(in: &subscriptions)
    }
}
