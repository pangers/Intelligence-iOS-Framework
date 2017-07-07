//
//  SequenceType+Intelligence.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

extension Sequence {
 
    /**
    Synchronously iterates over all items in the main thread
    and executes the body passed on each of them.
    
    - parameter body: The lambda to execute on each element
    */
    func forEachInMainThread(body: @escaping (Self.Iterator.Element) -> ()) {
        if (!Thread.isMainThread ) {
            
            let operation = BlockOperation() { () -> Void in
                self.forEachInMainThread(body: body)
            }
            OperationQueue.main.addOperations([operation], waitUntilFinished: true)
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
    func forEach(asyncInQueue queue:DispatchQueue, body: @escaping(Self.Iterator.Element) -> ()) {
        queue.async() {
            self.forEach(body)
        }
    }
}
