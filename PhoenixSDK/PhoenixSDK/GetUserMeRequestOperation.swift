//
//  GetUserMeRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// An operation to wrap the get user me request.
class GetUserMeRequestOperation : PhoenixNetworkRequestOperation {
    
    /// The user obtained
    var user: Phoenix.User?
    
    /// The configuration used throughout Phoenix.
    let configuration: PhoenixConfigurationProtocol
    
    let callback: PhoenixUserCallback

    /// Default initializer with all required parameters
    init(session:NSURLSession, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol, callback: PhoenixUserCallback) {
        self.configuration = configuration
        let request = NSURLRequest.phx_httpURLRequestForGetUserMe(configuration)
        self.callback = callback
        super.init(withSession: session, withRequest: request, withAuthentication: authentication)
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
        
        guard let data = self.output?.data else {
            return
        }
        
        // If all conditions succeed, parse the user.
        user = Phoenix.User.fromResponseData(data, withConfiguration:configuration)
        
    }

}