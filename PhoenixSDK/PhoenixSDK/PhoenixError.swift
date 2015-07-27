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