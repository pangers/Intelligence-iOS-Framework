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
    init(session:NSURLSession, user:Phoenix.User, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol) {
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: configuration)
        super.init(withSession: session, withRequest: request, withAuthentication: authentication)
        errorCode = IdentityError.UserCreationError.rawValue
        self.configuration = configuration
    }
    
}