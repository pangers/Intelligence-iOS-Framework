//
//  GetUserMeRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Get Me API.
internal final class GetUserMeRequestOperation : PhoenixNetworkRequestOperation {
    
    /// The user obtained
    var user: Phoenix.User?
    
    /// The configuration used throughout Phoenix.
    let configuration: Phoenix.Configuration
    let callback: PhoenixUserCallback
    
    /// Create new operation for Get Me API.
    /// - parameter session:        NSURLSession to use.
    /// - parameter authentication: Authentication class required for super class.
    /// - parameter configuration:  Configuration class used for configuring request.
    /// - returns: A new GetUserMeRequestOperation instance.
    init(session:NSURLSession, authentication:Phoenix.Authentication, configuration:Phoenix.Configuration, callback: PhoenixUserCallback) {
        self.configuration = configuration
        let request = NSURLRequest.phx_URLRequestForGetUserMe(configuration)
        self.callback = callback
        super.init(withSession: session, request: request, authentication: authentication)
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        
        // If after checking everything the user is nil, create an error.
        defer {
            if user == nil {
                error = NSError(domain: IdentityError.domain, code: IdentityError.GetUserError.rawValue, userInfo: nil)
            }
            
            // Set userId in authentication class (so we can use it in future requests requiring userId).
            authentication.userId = user?.userId
            self.callback(user: user, error: error)
        }
        
        if error != nil {
            return
        }
        
        guard let userDictionary = getFirstDataDictionary() else {
            error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
        
        // If all conditions succeed, parse the user.
        user = Phoenix.User(withJSON: userDictionary, configuration: configuration)
    }

}