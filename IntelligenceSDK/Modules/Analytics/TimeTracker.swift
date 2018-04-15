//
//  TimeTracker.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 09/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

let TrackEventType = "Intelligence.Analytics.Application.Time"

typealias TimeTrackerCallback = (_ event: TrackApplicationTimeEvent) -> Void

protocol TimeTrackerStorageProtocol {
    func seconds() -> UInt64?
    func update(seconds: UInt64)
    func reset()
}

class TimeTrackerStorage: TimeTrackerStorageProtocol {
    let storage: UserDefaults

    init(userDefaults: UserDefaults) {
       storage = userDefaults
    }

    func seconds() -> UInt64? {
        return (storage.object(forKey: TrackEventType) as? NSNumber)?.uint64Value
    }

    func update(seconds: UInt64) {
        // Store value.
        storage.set(NSNumber(value: seconds), forKey: TrackEventType)
        storage.synchronize()
    }

    func reset() {
        // Clear storage.
        storage.removeObject(forKey: TrackEventType)
        storage.synchronize()
    }
}

/// Responsible for tracking time between startup, pause, resume, and stop events.
class TimeTracker: NSObject {
    private let storageTimeInterval = 5.0
    private let callback: TimeTrackerCallback
    var backgroundThreshold: UInt64 = 5 * 60
    var seconds = UInt64(0)
    var backgroundTime: UInt64?
    var referenceTime: UInt64?
    private var timer: Timer?

    private let storage: TimeTrackerStorageProtocol

    init(storage: TimeTrackerStorageProtocol, callback: @escaping TimeTrackerCallback) {
        self.storage = storage
        self.callback = callback

        super.init()

        // On initialize, check if we had an unsent duration stored
        if let previousDuration = storage.seconds() {
            // Send it
            callback(TrackApplicationTimeEvent(withSeconds: previousDuration))
            // Clean the slate
            reset()
        }

        // Start new session
        start()
        createTimer()
    }

    deinit {
        store(resume: false)
        destroyTimer()
    }

    /// Increment seconds then clear reference time.
    private func stop() {
        if let startTime = referenceTime {
            seconds += elapsedSince(start: startTime)
            referenceTime = nil
        }
    }

    /// Record current reference time.
    private func start() {
        referenceTime = mach_absolute_time()
    }

    /// Resume counting, should be called when entering foreground.
    /// This may also send an event if we were backgrounded for longer than n minutes.
    func resume() {
        // When we enter the foreground we want to check how long we were in the background
        if let backgroundTime = backgroundTime {
            // If we were backgrounded longer than the threshold
            // we should sent the event and reset the seconds to zero.
            if elapsedSince(start: backgroundTime) > backgroundThreshold {
                store(resume: false)
                callback(TrackApplicationTimeEvent(withSeconds: seconds))
                reset()
            }
        }
        // Clear background value then start counting
        backgroundTime = nil
        start()
        createTimer()
    }

    /// Pause counting, should be called when entering background.
    func pause() {
        // When we enter the background we want to track the time we entered the background
        backgroundTime = mach_absolute_time()

        // Then stop the timer and store our current amount of seconds
        store(resume: false)
        destroyTimer()
    }

    /// Reset state.
    private func reset() {
        referenceTime = nil
        seconds = 0

        // Clear storage.
        storage.reset()
    }

    /// Store value in NSUserDefaults, stop counting, and optionally resume counting.
    private func store(resume: Bool) {
        stop()
        if resume {
            start()
        }

        // Store value.
        storage.update(seconds: seconds)
    }

    /// Calculate seconds elapsed since a starting reference time.
    private func elapsedSince(start: UInt64) -> UInt64 {
        let elapsed = mach_absolute_time() - start
        var timeBaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timeBaseInfo)
        let elapsedNano = elapsed * UInt64(timeBaseInfo.numer) / UInt64(timeBaseInfo.denom)
        return elapsedNano / 1_000_000_000
    }

    // MARK: - Timer

    private func createTimer() {
        timer = Timer(timeInterval: storageTimeInterval, target: self, selector: #selector(TimeTracker.runTimer(timer:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }

    private func destroyTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc func runTimer(timer: Timer) {
        store(resume: true)
    }
}
