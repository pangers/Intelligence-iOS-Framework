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
typealias PhoenixEventQueueCallback = (events: JSONDictionaryArray, completion: (error: NSError?) -> ()) -> ()

internal class PhoenixEventQueue {
    
    /// Current events we have to send, stored to disk when changed and loaded on hard launch.
    internal lazy var eventArray = JSONDictionaryArray()
    
    /// How often we should attempt to send events.
    private let eventInterval: NSTimeInterval = 10
    
    /// Callback used for propogating events up for another class to manage sending them.
    private let callback: PhoenixEventQueueCallback
    
    /// Maximum number of events to send in a single callback.
    internal let maxEvents = 100
    
    /// True if queue has been stopped (defaults to True).
    internal var isPaused = true
    
    /// True if we are sending items.
    private var isSending = false
    
    private var timer: NSTimer?
    
    /// Create new Event queue, loading any items on disk.
    /// - parameter callback: Callback used for propogating events back for sending.
    /// - returns: Instance of Event Queue.
    init(withCallback callback: PhoenixEventQueueCallback) {
        self.callback = callback
        loadEvents()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK:- Read/Write
    
    /// - returns: Path to Events json file.
    private func jsonPath() -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else { return nil }
        return "\(path)/Events.json"
    }
    
    /// Clear contents of file at `jsonPath()` (only used for testing).
    internal func clearEvents() {
        objc_sync_enter(self)
        if let path = jsonPath() {
            do { try NSFileManager.defaultManager().removeItemAtPath(path) }
            catch { }
        }
        objc_sync_exit(self)
    }
    
    /// Load events present in file at `jsonPath()`.
    internal func loadEvents() {
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
        timer = NSTimer.scheduledTimerWithTimeInterval(eventInterval, target: self, selector: Selector("runTimer"), userInfo: nil, repeats: true)
        objc_sync_exit(self)
    }
    
    /// Stop queue if it is currently running.
    func stopQueue() {
        objc_sync_enter(self)
        if isPaused { return }
        isPaused = true
        timer?.invalidate()
        timer = nil
        objc_sync_exit(self)
    }
    
    /// Timer callback for executing `fire()` method. Must be marked @objc for NSTimer selector to work.
    @objc internal func runTimer() {
        fire(withCompletion: nil)
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
    
    /// Attempt sending events to `callback` if possible.
    /// Won't execute if queue is paused, already sending, or there are no events to send.
    /// - parameter completion: Returns optional error if request fails. If nil, assume successful.
    /// - returns: Returns True if queue is not paused/sending and contains items.
    internal func fire(withCompletion completion: ((error: NSError?) -> ())?) -> Bool {
        objc_sync_enter(self)
        // Ensure we aren't already sending, paused, and have events to send.
        if isSending || isPaused || eventArray.count == 0 { return false }
        // Calculate end index.
        let endIndex = eventArray.endIndex > maxEvents ? maxEvents : eventArray.endIndex
        // Store range, so we know what to remove.
        let range = Range(start: eventArray.startIndex, end: endIndex)
        // Set sending to true.
        isSending = true
        // Send events to function.
        callback(events: eventArray) { [weak self] (error) in
            guard let this = self else { return }
            objc_sync_enter(this)
            // If successful, remove this range.
            if error == nil {
                // Remove items in range we just sent.
                this.eventArray.removeRange(range)
                // Store remaining items.
                this.storeEvents()
            }
            completion?(error: error)
            // No longer sending items.
            this.isSending = false
            objc_sync_exit(this)
        }
        objc_sync_exit(self)
        return true
    }
}