//
//  GetUserMeRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation to get me, inherits from PhoenixUserRequestOperation, which performs most of
/// necessary parsing and error handling.
class GetUserMeRequestOperation : PhoenixUserRequestOperation {
    
    /// Default initializer with all required parameters
    init(session:NSURLSession, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol) {
        let request = NSURLRequest.phx_httpURLRequestForGetUserMe(configuration)
        super.init(withSession: session, withRequest: request, withAuthentication: authentication)
        errorCode = IdentityError.InvalidUserError.rawValue
        self.configuration = configuration
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        // Set userId in authentication class (so we can use it in future requests requiring userId).
        authentication.userId = user?.userId
    }
}