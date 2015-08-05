//
//  CreateUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class CreateUserRequestOperation : PhoenixUserRequestOperation {
    
    /// Default initializer with all required parameters
    init(session:NSURLSession, user:PhoenixUser, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol) {
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: configuration)
        super.init(withSession: session, withRequest: request, withAuthentication: authentication)
        self.configuration = configuration
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        // Check for network errors
        if self.error != nil {
            self.error = NSError(domain: IdentityError.domain, code: IdentityError.UserCreationError.rawValue, userInfo: nil)
            return
        }
        // If the parse failed, return an error.
        if self.user == nil {
            self.error = NSError(domain: IdentityError.domain, code: IdentityError.UserCreationError.rawValue, userInfo: nil)
        }
    }
}