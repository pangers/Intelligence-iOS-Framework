//
//  PhoenixError.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

// TODO: Improve these descriptions.
/// Errors that can occur during Configuration.
public enum ConfigurationError: Int, ErrorType {
    
    /// Configuration file does not exist.
    case FileNotFoundError = 1001
    
    /// Property is invalid.
    case InvalidPropertyError = 1002
    
    /// Configuration file is in incorrect format.
    case InvalidFileError = 1003
    
    /// Property is missing.
    case MissingPropertyError = 1004
}