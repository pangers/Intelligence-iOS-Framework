//
//  PhoenixEventQueue.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 18/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

typealias PhoenixEventQueueCallback = (JSONDictionaryArray, (Bool) -> ()) -> ()

internal class PhoenixEventQueue {
    
    private lazy var eventArray = JSONDictionaryArray()
    private let eventInterval: NSTimeInterval = 1
    private let callback: PhoenixEventQueueCallback
    private let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    private var isPaused = true
    private var isSending = false
    
    init(withCallback callback: PhoenixEventQueueCallback) {
        self.callback = callback
        loadEvents()
    }
    
    // MARK:- Read/Write
    
    private func jsonPath() -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else { return nil }
        return "\(path)/Events.json"
    }
    
    private func loadEvents() {
        objc_sync_enter(self)
        if let path = jsonPath(), data = NSData(contentsOfFile: path)?.phx_jsonDictionaryArray {
            eventArray = data
        }
        objc_sync_exit(self)
    }
    
    private func storeEvents() {
        objc_sync_enter(self)
        // Store to disk.
        if let path = jsonPath(), data = self.eventArray.phx_toJSONData() {
            data.writeToFile(path, atomically: true)
        }
        objc_sync_exit(self)
    }
    
    
    // MARK:- Queueing
    
    func startQueue() {
        objc_sync_enter(self)
        isPaused = false
        runTimer()
        objc_sync_exit(self)
    }
    
    func stopQueue() {
        objc_sync_enter(self)
        isPaused = true
        objc_sync_exit(self)
    }
    
    func enqueueEvent(event: JSONDictionary) {
        objc_sync_enter(self)
        // Add event
        eventArray.append(event)
        // Store our changed events array
        storeEvents()
        objc_sync_exit(self)
    }
    
    private func runTimer() {
        let seconds = eventInterval
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        let currQueue = NSOperationQueue.currentQueue()
        dispatch_after(dispatchTime, queue, { [weak self] in
            self?.fire()
            currQueue?.addOperationWithBlock({ [weak self] () -> Void in
                self?.runTimer()
            })
        })
    }
    
    private func fire() {
        objc_sync_enter(self)
        if !isSending && !isPaused && eventArray.count > 0 {
            // Store range, so we know what to remove.
            let maxItems = 100
            let endIndex = eventArray.endIndex > maxItems ? maxItems : eventArray.endIndex
            let range = Range(start: eventArray.startIndex, end: endIndex)
            isSending = true
            callback(eventArray) { [weak self] (success) in
                guard let this = self else { return }
                objc_sync_enter(this)
                if success {
                    // Remove items in range we just sent
                    this.eventArray.removeRange(range)
                    // Store remaining items
                    this.storeEvents()
                }
                this.isSending = false
                objc_sync_exit(this)
            }
        }
        objc_sync_exit(self)
    }
}