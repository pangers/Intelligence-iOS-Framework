//
//  PhoenixTimeTracker.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 09/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

typealias PhoenixTimeTrackerCallback = (event: TrackApplicationTimeEvent) -> ()

/// Responsible for tracking time between startup, pause, resume, and stop events.
class PhoenixTimeTracker: NSObject {
    private let storageTimeInterval = 5.0
    private let backgroundThreshold: UInt64 = 5 * 60
    private let callback: PhoenixTimeTrackerCallback
    private let storage = NSUserDefaults.standardUserDefaults()
    private var seconds = UInt64(0)
    private var backgroundTime: UInt64?
    private var referenceTime: UInt64?
    private var timer: NSTimer?
    
    init(callback: PhoenixTimeTrackerCallback) {
        self.callback = callback
        
        super.init()
        
        // On initialize, check if we had an unsent duration stored
        if let previousDuration = storage.objectForKey(TrackEventType) as? NSNumber {
            // Send it
            callback(event: TrackApplicationTimeEvent(withSeconds: previousDuration.unsignedLongLongValue))
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
            seconds += elapsedSince(startTime)
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
            if elapsedSince(backgroundTime) > backgroundThreshold {
                store(resume: false)
                callback(event: TrackApplicationTimeEvent(withSeconds: seconds))
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
        storage.removeObjectForKey(TrackEventType)
        storage.synchronize()
    }
    
    /// Store value in NSUserDefaults, stop counting, and optionally resume counting.
    private func store(resume resume: Bool) {
        stop()
        if resume {
            start()
        }
        
        // Store value.
        storage.setObject(NSNumber(unsignedLongLong: seconds), forKey: TrackEventType)
        storage.synchronize()
    }
    
    /// Calculate seconds elapsed since a starting reference time.
    private func elapsedSince(start: UInt64) -> UInt64 {
        let elapsed = mach_absolute_time() - start
        var timeBaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timeBaseInfo)
        let elapsedNano = elapsed * UInt64(timeBaseInfo.numer) / UInt64(timeBaseInfo.denom);
        return elapsedNano / 1_000_000_000
    }
    
    // MARK: - Timer
    
    private func createTimer() {
        timer = NSTimer(timeInterval: storageTimeInterval, target: self, selector: "runTimer:", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    private func destroyTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    internal func runTimer(timer: NSTimer) {
        store(resume: true)
    }
}