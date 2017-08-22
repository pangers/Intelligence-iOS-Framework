//
//  EventQueue.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 18/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Callback used for propogating events up for another class to manage sending them. 
/// Takes a JSONDictionaryArray and relies on callee returning success/failure on response from server.
typealias EventQueueCallback = (JSONDictionaryArray, @escaping (NSError?) -> ()) -> ()

internal class EventQueue: NSObject {
    
    /// A private semaphore.
    private let semaphore = NSObject()
    
    /// Current events we have to send, stored to disk when changed and loaded on hard launch.
    internal lazy var eventArray = JSONDictionaryArray()
    
    /// How often we should attempt to send events.
    private let eventInterval: TimeInterval = 10
    
    /// Callback used for propogating events up for another class to manage sending them.
    private let callback: EventQueueCallback
    
    /// Maximum number of events to send in a single callback.
    internal let maxEvents = 100
    
    /// True if queue has been stopped (defaults to True).
    internal var isPaused = true
    
    /// True if we are sending items.
    private var isSending = false
    
    private var timer: Timer?
    
    /// Create new Event queue, loading any items on disk.
    /// - parameter callback: Callback used for propogating events back for sending.
    /// - returns: Instance of Event Queue.
    init(withCallback callback: @escaping EventQueueCallback) {
        self.callback = callback
        super.init()
        loadEvents()
    }
    
    deinit {
        stopQueue()
    }
    
    // MARK:- Read/Write
    
    /// - returns: Path to Events json file.
    internal func jsonPath() -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return nil }
        return "\(path)/Events.json"
    }
    
    /// Clear contents of file at `jsonPath()` (only used for testing).
    internal func clearEvents() {
        synced(lock: semaphore) {
            if let path = self.jsonPath() {
                _ = try? FileManager.default.removeItem(atPath: path)
            }
        }
    }
    
    /// Load events present in file at `jsonPath()`.
    internal func loadEvents() {
        synced(lock: semaphore) {
            if let path = self.jsonPath(), let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped).int_jsonDictionaryArray {
                self.eventArray = data!
            }
        }
    }
    
    /// Save events to file at `jsonPath()`.
    /// The caller is responsible to sync the call.
    private func storeEvents() {
        if let path = self.jsonPath(), let data = self.eventArray.int_toJSONData() {
            try! data.write(to: URL(fileURLWithPath: path), options: .atomic)
        }
    }
    
    // MARK:- Queueing
    
    /// Start queue if it was paused.
    func startQueue() {
        synced(lock: semaphore) {
            if !self.isPaused {
                return
            }
            
            self.isPaused = false
            self.timer = Timer(timeInterval: self.eventInterval, target: self, selector: #selector(EventQueue.runTimer(timer:)), userInfo: nil, repeats: true)
            RunLoop.main.add(self.timer!, forMode: .commonModes)
        }
    }
    
    /// Stop queue if it is currently running.
    func stopQueue() {
        synced(lock: semaphore) {
            if self.isPaused {
                return
            }
            self.isPaused = true
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    /// Timer callback for executing `fire()` method. Must be marked @objc for NSTimer selector to work.
    @objc internal func runTimer(timer: Timer) {
        fire(withCompletion: nil)
    }
    
    /// Add the JSON representation of an Event to the queue.
    func enqueueEvent(event: JSONDictionary) {
        synced(lock: semaphore) {
            // Add event and store
            self.eventArray.append(event)
            self.storeEvents()
        }
    }
    
    /// Attempt sending events to `callback` if possible.
    /// Won't execute if queue is paused, already sending, or there are no events to send.
    /// - parameter completion: Returns optional error if request fails. If nil, assume successful.
    /// - returns: Returns True if queue is not paused/sending and contains items.
    @discardableResult
    internal func fire(withCompletion completion: ((_ error: NSError?) -> ())?) -> Bool {
        var result = false
        
        synced(lock: semaphore) {
            // Ensure we aren't already sending, paused, and have events to send.
            if self.isSending || self.isPaused || self.eventArray.count == 0 {
                return
            }
            
            result = true
            
            // Calculate end index.
            let endIndex = self.eventArray.endIndex > self.maxEvents ? self.maxEvents : self.eventArray.endIndex
            
            // Store range, so we know what to remove.
            let range = self.eventArray.startIndex ..< endIndex
            
            // Set sending to true.
            self.isSending = true
            
            // Send events to function.
            let eventsToSend = Array(self.eventArray.prefix(upTo: endIndex))
            
            self.callback(eventsToSend) { [weak self] (error) in
                guard let this = self else {
                    return
                }
                
                synced(lock: this.semaphore) {
                    // If successful or outdated events, remove this range.
                    if error == nil || error?.code == AnalyticsError.oldEventsError.rawValue {
                        // Remove items in range we just sent and store again
                        this.eventArray.removeSubrange(range)
                        this.storeEvents()
                    }
                    
                    completion?(error)
                    
                    // No longer sending items.
                    this.isSending = false
                }
            }
        }
        
        return result
    }
}
