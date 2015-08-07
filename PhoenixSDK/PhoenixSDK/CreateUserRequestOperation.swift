//
//  CreateUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation to create a user, inherits from PhoenixUserRequestOperation, which performs most of
/// necessary parsing and error handling.
final internal class CreateUserRequestOperation : PhoenixUserRequestOperation {
    
    /// Default initializer with all required parameters
    init(withSession session:NSURLSession, user:PhoenixUser, authentication:Phoenix.Authentication, configuration:Phoenix.Configuration) {
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: configuration)
        super.init(withSession: session, request: request, authentication: authentication)
        errorCode = IdentityError.UserCreationError.rawValue
        self.configuration = configuration
    }
    
}