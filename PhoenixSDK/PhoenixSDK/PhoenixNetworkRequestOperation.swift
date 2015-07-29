//
//  NetworkRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class PhoenixNetworkRequestOperation : TSDOperation<NSURLRequest, (data:NSData?, response:NSHTTPURLResponse?)> {
    
    let sessionManager:NSURLSession
    let request:NSURLRequest
    let authentication:Phoenix.Authentication
    
    /// Default initializer with all required parameters
    init(withSession session:NSURLSession, withRequest request:NSURLRequest, withAuthentication authentication:Phoenix.Authentication) {
        self.sessionManager = session
        self.request = request
        self.authentication = authentication
    }
    
    // The operation will run synchronously the data task.
    override func main() {
        // Mutate request, adding bearer token
        guard let preparedRequest = request.phx_preparePhoenixRequest(withAuthentication: self.authentication) else {
            assert(false, "Should never occur unless we override request and don't create mutable copies of it.")
            return
        }
        
        let (data, response, error) = sessionManager.phx_executeSynchronousDataTaskWithRequest(preparedRequest)
        
        self.error = error
        self.output = (data:data, response:response as? NSHTTPURLResponse)
    }
    

}
