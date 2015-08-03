//
//  NetworkRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Allows to perform a request operation, receiving as input an NSURLRequest, and yielding
/// as output a struct with the data and the response. In the operation error the error of the request can be fetched.
internal class PhoenixNetworkRequestOperation : TSDOperation<NSURLRequest, (data:NSData?, response:NSHTTPURLResponse?)> {
    
    /// The URL session to use
    private let urlSession:NSURLSession
    
    /// The request that will be executed
    private let request:NSURLRequest
    
    /// The Phoenix authentication to prepare the request with.
    private let authentication:Phoenix.Authentication
    
    /// Default initializer with all required parameters
    init(withSession session:NSURLSession, withRequest request:NSURLRequest, withAuthentication authentication:Phoenix.Authentication) {
        self.urlSession = session
        self.request = request
        self.authentication = authentication
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        // Mutate request, adding bearer token
        let preparedRequest = request.phx_preparePhoenixRequest(withAuthentication: self.authentication)
        
        let (data, response, error) = urlSession.phx_executeSynchronousDataTaskWithRequest(preparedRequest)
        
        self.error = error
        self.output = (data:data, response:response as? NSHTTPURLResponse)
    }
    

}
