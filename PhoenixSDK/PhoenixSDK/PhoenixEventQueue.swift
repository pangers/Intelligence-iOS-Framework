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
    
    /// A private semaphore.
    private let semaphore = NSObject()
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("enteredBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("enteredForeground:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    @objc func enteredBackground(notification: NSNotification) {
        stopQueue()
    }
    
    @objc func enteredForeground(notification: NSNotification) {
        startQueue()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        timer?.invalidate()
    }
    
    // MARK:- Read/Write
    
    /// - returns: Path to Events json file.
    internal func jsonPath() -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else { return nil }
        return "\(path)/Events.json"
    }
    
    /// Clear contents of file at `jsonPath()` (only used for testing).
    internal func clearEvents() {
        synced(semaphore) {
            if let path = self.jsonPath() {
                _ = try? NSFileManager.defaultManager().removeItemAtPath(path)
            }
        }
    }
    
    /// Load events present in file at `jsonPath()`.
    internal func loadEvents() {
        synced(semaphore) {
            if let path = self.jsonPath(), data = NSData(contentsOfFile: path)?.phx_jsonDictionaryArray {
                self.eventArray = data
            }
        }
    }
    
    /// Save events to file at `jsonPath()`.
    /// The caller is responsible to sync the call.
    private func storeEvents() {
        // Store to disk.
        if let path = self.jsonPath(), data = self.eventArray.phx_toJSONData() {
            data.writeToFile(path, atomically: true)
        }
    }
    
    // MARK:- Queueing
    
    /// Start queue if it was paused.
    func startQueue() {
        synced(semaphore) {
            if !self.isPaused {
                return
            }
            
            self.isPaused = false
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.eventInterval, target: self, selector: Selector("runTimer"), userInfo: nil, repeats: true)
        }

    }
    
    /// Stop queue if it is currently running.
    func stopQueue() {
        synced(semaphore) {
            if self.isPaused {
                return
            }
            self.isPaused = true
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    /// Timer callback for executing `fire()` method. Must be marked @objc for NSTimer selector to work.
    @objc internal func runTimer() {
        fire(withCompletion: nil)
    }
    
    /// Add the JSON representation of an Event to the queue.
    func enqueueEvent(event: JSONDictionary) {
        synced(semaphore) {
            // Add event and store
            self.eventArray.append(event)
            self.storeEvents()
        }
    }
    
    /// Attempt sending events to `callback` if possible.
    /// Won't execute if queue is paused, already sending, or there are no events to send.
    /// - parameter completion: Returns optional error if request fails. If nil, assume successful.
    /// - returns: Returns True if queue is not paused/sending and contains items.
    internal func fire(withCompletion completion: ((error: NSError?) -> ())?) -> Bool {
        var result = false
        
        synced(semaphore) {
            // Ensure we aren't already sending, paused, and have events to send.
            if self.isSending || self.isPaused || self.eventArray.count == 0 {
                return
            }
            
            result = true
            
            // Calculate end index.
            let endIndex = self.eventArray.endIndex > self.maxEvents ? self.maxEvents : self.eventArray.endIndex
            
            // Store range, so we know what to remove.
            let range = Range(start: self.eventArray.startIndex, end: endIndex)
            
            // Set sending to true.
            self.isSending = true
            
            // Send events to function.
            let eventsToSend = Array(self.eventArray.prefixUpTo(endIndex))
            
            self.callback(events: eventsToSend) { [weak self] (error) in
                guard let this = self else {
                    return
                }
                
                synced(this.semaphore) {
                    
                    // If successful, remove this range.
                    if error == nil {
                        // Remove items in range we just sent and store again
                        this.eventArray.removeRange(range)
                        this.storeEvents()
                    }
                    
                    completion?(error: error)
                    
                    // No longer sending items.
                    this.isSending = false
                }
            }
        }
        
        return result
    }
}