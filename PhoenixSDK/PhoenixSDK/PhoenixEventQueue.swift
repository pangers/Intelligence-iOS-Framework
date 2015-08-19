//
//  PhoenixEventQueue.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 18/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Callback used for propogating events up for another class to manage sending them. 
/// Takes a JSONDictionaryArray and relies on callee returning success/failure on response from server.
typealias PhoenixEventQueueCallback = (events: JSONDictionaryArray, (success: Bool) -> ()) -> ()

internal class PhoenixEventQueue {
    
    /// Current events we have to send, stored to disk when changed and loaded on hard launch.
    private lazy var eventArray = JSONDictionaryArray()
    
    /// How often we should attempt to send events.
    private let eventInterval: NSTimeInterval = 10
    
    /// Callback used for propogating events up for another class to manage sending them.
    private let callback: PhoenixEventQueueCallback
    
    /// Queue to execute callback on.
    private let dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    /// Maximum number of events to send in a single callback.
    private let maxEvents = 100
    
    /// True if queue has been stopped (defaults to True).
    private var isPaused = true
    
    /// True if we are sending items.
    private var isSending = false
    
    /// Create new Event queue, loading any items on disk.
    /// - parameter callback: Callback used for propogating events back for sending.
    /// - returns: Instance of Event Queue.
    init(withCallback callback: PhoenixEventQueueCallback) {
        self.callback = callback
        loadEvents()
    }
    
    // MARK:- Read/Write
    
    /// - returns: Path to Events json file.
    private func jsonPath() -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else { return nil }
        return "\(path)/Events.json"
    }
    
    /// Load events present in file at `jsonPath()`.
    private func loadEvents() {
        objc_sync_enter(self)
        if let path = jsonPath(), data = NSData(contentsOfFile: path)?.phx_jsonDictionaryArray {
            eventArray = data
        }
        objc_sync_exit(self)
    }
    
    /// Save events to file at `jsonPath()`.
    private func storeEvents() {
        objc_sync_enter(self)
        // Store to disk.
        if let path = jsonPath(), data = self.eventArray.phx_toJSONData() {
            data.writeToFile(path, atomically: true)
        }
        objc_sync_exit(self)
    }
    
    
    // MARK:- Queueing
    
    /// Start queue if it was paused.
    func startQueue() {
        objc_sync_enter(self)
        if !isPaused { return }
        isPaused = false
        runTimer()
        objc_sync_exit(self)
    }
    
    /// Stop queue if it is currently running.
    func stopQueue() {
        objc_sync_enter(self)
        if isPaused { return }
        isPaused = true
        objc_sync_exit(self)
    }
    
    /// Add the JSON representation of an Event to the queue.
    func enqueueEvent(event: JSONDictionary) {
        objc_sync_enter(self)
        // Add event
        eventArray.append(event)
        // Store our changed events array
        storeEvents()
        objc_sync_exit(self)
    }
    
    /// Wait `eventInterval` before executing `fire()` method.
    private func runTimer() {
        // Dispatch the fire method after `eventInterval`
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(eventInterval * Double(NSEC_PER_SEC)))
        // Store current queue, so we aren't blocked by events on the `dispatchQueue`.
        let currQueue = NSOperationQueue.currentQueue()
        dispatch_after(dispatchTime, dispatchQueue, { [weak self] in
            self?.fire()
            currQueue?.addOperationWithBlock({ [weak self] () -> Void in
                self?.runTimer()
            })
        })
    }
    
    /// Attempt sending events to `callback` if possible.
    /// Might fail if queue is paused, already sending, or there are no events to send.
    private func fire() {
        objc_sync_enter(self)
        // Ensure we aren't already sending, paused, and have events to send.
        if isSending || isPaused || eventArray.count == 0 { return }
        // Calculate end index.
        let endIndex = eventArray.endIndex > maxEvents ? maxEvents : eventArray.endIndex
        // Store range, so we know what to remove.
        let range = Range(start: eventArray.startIndex, end: endIndex)
        // Set sending to true.
        isSending = true
        // Send events to function.
        callback(events: eventArray) { [weak self] (success) in
            guard let this = self else { return }
            objc_sync_enter(this)
            // If successful, remove this range.
            if success {
                // Remove items in range we just sent.
                this.eventArray.removeRange(range)
                // Store remaining items.
                this.storeEvents()
            }
            // No longer sending items.
            this.isSending = false
            objc_sync_exit(this)
        }
        objc_sync_exit(self)
    }
}