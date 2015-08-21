//
//  UpdateUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 07/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

/// Operation for Update User API.
class UpdateUserRequestOperation: PhoenixNetworkRequestOperation {

    /// The output user created, as provided by the backend.
    var user: Phoenix.User?
    
    /// The configuration used through Phoenix.
    let configuration: Phoenix.Configuration
    
    /// Create new operation for User User API.
    /// - parameter session:        NSURLSession to use.
    /// - parameter user:           User object containing details we want to update (requires userId).
    /// - parameter authentication: Authentication class required for super class.
    /// - parameter configuration:  Configuration class used for configuring request.
    /// - returns: A new UpdateUserRequestOperation instance.
    init(session:NSURLSession, user:Phoenix.User, authentication:Phoenix.Authentication, configuration:Phoenix.Configuration) {
        self.configuration = configuration
        let request = NSURLRequest.phx_URLRequestForUpdateUser(user, configuration: configuration)
        
        super.init(withSession: session, request: request, authentication: authentication)
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        
        // If after checking everything the user is nil, create an error.
        defer {
            if user == nil {
                error = NSError(domain: IdentityError.domain, code: IdentityError.UserUpdateError.rawValue, userInfo: nil)
            }
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
