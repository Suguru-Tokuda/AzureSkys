//
//  RefreshSchedulerTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/2/26.
//

import XCTest
@testable import AzureSkys

@MainActor
final class RefreshSchedulerTests: XCTestCase {
    func testImmediateLoadQuietRepeatsAndStop() async {
        let scheduler = RefreshScheduler()
        let repeats = expectation(description: "Initial load and quiet repeat")
        repeats.expectedFulfillmentCount = 2
        var flags: [Bool] = []
        scheduler.start(interval: 0.01, showLoading: true) { flag in
            flags.append(flag)
            if flags.count <= 2 { repeats.fulfill() }
        }
        await fulfillment(of: [repeats], timeout: 2)
        scheduler.stop()
        XCTAssertEqual(Array(flags.prefix(2)), [true, false])
        let count = flags.count
        try? await Task.sleep(for: .milliseconds(40))
        XCTAssertEqual(flags.count, count)
    }

    func testSchedulerDeallocatesAndStopsRepeats() async {
        var scheduler: RefreshScheduler? = RefreshScheduler()
        weak var weakScheduler = scheduler
        let initial = expectation(description: "Initial load")
        var calls = 0
        scheduler?.start(interval: 0.05, showLoading: true) { _ in
            calls += 1
            if calls == 1 { initial.fulfill() }
        }
        await fulfillment(of: [initial], timeout: 2)
        scheduler = nil
        XCTAssertNil(weakScheduler)
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(calls, 1)
    }

    func testRestartWaitsForCanceledRefreshToUnwind() async {
        let scheduler = RefreshScheduler()
        let oldStarted = expectation(description: "Old request started")
        let newStarted = expectation(description: "Replacement request started")
        var release: CheckedContinuation<Void, Never>?
        var active = false
        var replacementCalls = 0
        scheduler.start(interval: 60, showLoading: true) { _ in
            active = true
            oldStarted.fulfill()
            // This operation deliberately ignores task cancellation until released.
            await withCheckedContinuation { release = $0 }
            active = false
        }
        await fulfillment(of: [oldStarted], timeout: 2)
        scheduler.start(interval: 60, showLoading: false) { flag in
            XCTAssertFalse(active)
            XCTAssertFalse(flag)
            replacementCalls += 1
            newStarted.fulfill()
        }
        for _ in 0..<10 { await Task.yield() }
        XCTAssertEqual(replacementCalls, 0)
        release?.resume()
        await fulfillment(of: [newStarted], timeout: 2)
        scheduler.stop()
        XCTAssertEqual(replacementCalls, 1)
    }

}
