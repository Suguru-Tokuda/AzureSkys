//
//  RefreshScheduler.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/1/26.
//

import Foundation

/// Runs one refresh at a time, with an immediate load followed by periodic loads.
@MainActor
final class RefreshScheduler {
    private var task: Task<Void, Never>?
    private(set) var isRunning = false

    func start(
        interval: TimeInterval = 300,
        showLoading: Bool,
        refresh: @escaping @MainActor (Bool) async -> Void
    ) {
        let previousTask = task

        previousTask?.cancel()
        isRunning = true
        task = Task {
            // A restarted schedule waits for the cancelled request to finish unwinding.
            await previousTask?.value

            guard !Task.isCancelled else {
                return
            }

            await refresh(showLoading)

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(interval))
                } catch {
                    return
                }

                guard !Task.isCancelled else {
                    return
                }

                await refresh(false)
            }
        }
    }

    func stop() {
        isRunning = false
        task?.cancel()
    }

    deinit {
        task?.cancel()
    }
}
