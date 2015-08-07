//
//  GetUserByIdRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

/// Operation used to retrieve a user data based on its id.
class GetUserByIdRequestOperation: PhoenixNetworkRequestOperation {

    /// The user that was loaded during the request. Can be nil if the request failed or didn't yet occur.
    var user: Phoenix.User?
    
    /// The configuration that is in use in Phoenix.
    let configuration: PhoenixConfigurationProtocol
    
    /// Default initializer with all required parameters
    init(session:NSURLSession, userId:Int, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol) {
        self.configuration = configuration
        let request = NSURLRequest.phx_httpURLRequestForGetUserById(userId,withConfiguration:configuration)
        
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
