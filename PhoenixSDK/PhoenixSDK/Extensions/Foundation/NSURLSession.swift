//
//  NSURLSessionManager.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal extension NSURLSession {

    func phx_executeSynchronousDataTaskWithRequest(request: NSURLRequest) -> (data:NSData?, response:NSURLResponse?, error:NSError?) {
        let semaphore = dispatch_semaphore_create(0)
        
        var taskData:NSData?
        var taskResponse:NSURLResponse?
        var taskError:NSError?
        
        let dataTask = self.dataTaskWithRequest(request){ (data, response, error) in
            taskData = data
            taskResponse = response
            taskError = error
            
            dispatch_semaphore_signal(semaphore)
        }

        dataTask.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

        return (taskData,taskResponse,taskError)
    }
    
}