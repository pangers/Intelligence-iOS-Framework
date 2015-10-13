//
//  SequenceType+Phoenix.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

extension SequenceType {
 
    /**
    Synchronously iterates over all items in the main thread
    and executes the body passed on each of them.
    
    - parameter body: The lambda to execute on each element
    */
    func forEachInMainThread(body: (Self.Generator.Element) -> ()) {
        if ( !NSThread.isMainThread() ) {
            
            let operation = NSBlockOperation() { () -> Void in
                self.forEachInMainThread(body)
            }
            
            NSOperationQueue.mainQueue().addOperations([operation], waitUntilFinished: true)
        }
        else {
            forEach(body)
        }
    }

    /**
    Runs asynchonously in the given queue the lambda passed on each of the elements.
    
    - parameter queue: The queue to use.
    - parameter body:  The lambda to to execute.
    */
    func forEach(asyncInQueue queue:dispatch_queue_t, body: (Self.Generator.Element) -> ()) {
        dispatch_async(queue) {
            self.forEach(body)
        }
    }
}