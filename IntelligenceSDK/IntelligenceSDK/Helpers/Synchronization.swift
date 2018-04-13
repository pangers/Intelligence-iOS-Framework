//
//  Synchronization.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 02/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/**
Assures that only one thread at a time will enter the closures passed for the given lock.

Consider that passing self might be bad since other classes can use your object as a lock, and lead
to deadlocks.

- parameter lock:    The lock to use as a semaphore
- parameter closure: The closure to run thread safely.
*/
func synced(lock: AnyObject, closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}
