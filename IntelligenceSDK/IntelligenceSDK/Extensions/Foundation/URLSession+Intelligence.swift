//
//  NSURLSession+Intelligence.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal extension URLSession {

    /// Executes synchronously the passed request.
    /// - Parameter request: The request to perform.
    /// - Returns: A struct containing the data, response and error of the request performed.
    func int_executeSynchronousDataTask(with request: URLRequest) -> (data:Data?, response:URLResponse?, error: NSError?) {
        let semaphore = DispatchSemaphore(value: 0)
        
        var taskData:Data?
        var taskResponse:URLResponse?
        var taskError:Error?
        
        let dataTask = self.dataTask(with: request){ (data, response, error) in
            taskData = data
            taskResponse = response
            taskError = error
            
            semaphore.signal()
        }

        dataTask.resume()
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)

        return (taskData,taskResponse,taskError as
            NSError?)
    }
    
}
