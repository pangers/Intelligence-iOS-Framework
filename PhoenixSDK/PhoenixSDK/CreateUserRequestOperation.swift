//
//  CreateUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation to wrap the create user request.
class CreateUserRequestOperation : PhoenixNetworkRequestOperation {
    
    /// The output user created, as provided by the backend
    var user: Phoenix.User?
    
    /// The configuration used through Phoenix.
    let configuration: PhoenixConfigurationProtocol

    /// Default initializer with all required parameters
    init(session:NSURLSession, user:Phoenix.User, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol) {
        self.configuration = configuration
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: configuration)
        
        super.init(withSession: session, withRequest: request, withAuthentication: authentication)
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        
        // If after checking everything the user is nil, create an error.
        defer {
            if user == nil {
                error = NSError(domain: IdentityError.domain, code: IdentityError.UserCreationError.rawValue, userInfo: nil)
            }
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