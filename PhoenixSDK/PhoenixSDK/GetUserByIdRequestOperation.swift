//
//  GetUserByIdRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

/// Operation for Get User API.
internal final class GetUserByIdRequestOperation: PhoenixNetworkRequestOperation {

    /// The user that was loaded during the request. Can be nil if the request failed or didn't yet occur.
    var user: Phoenix.User?
    
    /// The configuration that is in use in Phoenix.
    let configuration: Phoenix.Configuration
    
    /// Create new operation for Get User API.
    /// - parameter session:        NSURLSession to use.
    /// - parameter userId:         ID of user to retrieve.
    /// - parameter authentication: Authentication class required for super class.
    /// - parameter configuration:  Configuration class used for configuring request.
    /// - returns: A new GetUserByIdRequestOperation instance.
    init(session:NSURLSession, userId:Int, authentication:Phoenix.Authentication, configuration:Phoenix.Configuration) {
        self.configuration = configuration
        let request = NSURLRequest.phx_URLRequestForGetUserById(userId,withConfiguration:configuration)
        
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
