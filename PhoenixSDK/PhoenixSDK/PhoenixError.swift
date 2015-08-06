//
//  PhoenixError.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Enumeration that defines the possible errors that can occur during
/// the initial setup of Phoenix's configuration.
/// Refer to the Readme file to obtain further instructions on setup.
public enum ConfigurationError: Int, ErrorType {
    
    /// Configuration file does not exist.
    case FileNotFoundError = 1001
    
    /// A property is invalid.
    case InvalidPropertyError = 1002
    
    /// Configuration file is invalid
    /// (Couldn't parse into a JSON or had an issue while reading it)
    case InvalidFileError = 1003
    
    /// There is a missing property in the configuration.
    case MissingPropertyError = 1004
}

/// Enumeration to list the errors that can occur in the identity module.
public enum IdentityError: Int, ErrorType {
    
    /// The domain passed to NSErrors.
    static let domain = "IdentityError"

    /// The user creation request couldn't complete successfully.
    case UserCreationError = 2001
    
    /// The user is invalid.
    case InvalidUserError = 2002

    /// The user retrieval request was unsuccessful.
    case GetUserError = 2003

}


/// Enumeration to list the errors that can occur in the identity module.
public enum RequestError: Int, ErrorType {
    
    /// The domain passed to NSErrors.
    static let domain = "RequestError"
    
    /// The request failed with a non 200 error code.
    case RequestFailedError = 3001

    /// The authentication operation failed, canceling all 
    /// pending operations.
    case AuthenticationFailedError = 3002

}