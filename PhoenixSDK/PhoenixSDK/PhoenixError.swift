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
    
    /// The domain passed to NSErrors.
    static let domain = "ConfigurationError"
    
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
    
    /// The password provided is too weak. See `Phoenix.User` password field to see
    /// the security requirements of the password.
    case WeakPasswordError = 2003

    /// The user retrieval request was unsuccessful.
    case GetUserError = 2004
    
    /// The user update request was not finished successfully.
    case UserUpdateError = 2005
    
    /// Login failed.
    case LoginFailed = 2006

    /// The user role assignment operation failed.
    case UserRoleAssignmentError = 2007
}

/// Enumeration to list the errors that can occur in any request.
public enum RequestError: Int, ErrorType {
    
    /// The domain passed to NSErrors.
    static let domain = "RequestError"
    
    /// The request failed with a non 200 error code.
    case RequestFailedError = 3001
    
    /// The authentication operation failed, canceling all 
    /// pending operations.
    case AuthenticationFailedError = 3002
    
    /// Error to return when parsing JSON fails.
    case ParseError = 3003
    
    /// Error to return if user doesn't have access to a particular API.
    case AccessDeniedError = 3004
}

/// Enumeration to list the errors that can occur in the installation module
internal enum InstallationError: Int, ErrorType {
    /// The domain passed to NSErrors.
    static let domain = "InstallationError"
    
    case CreateInstallationError = 4001
    
    case UpdateInstallationError = 4002
    
    /// Called 'create' method unnecessarily.
    case AlreadyInstalledError = 4003
    
    /// Called 'update' method unnecessarily.
    case AlreadyUpdatedError = 4004
}

/// These are internal errors thrown by the Geofence class. Hence the custom Enum type.
internal enum GeofenceError: ErrorType {
    
    /// Error to return when we have a property error. Internal use only.
    case InvalidPropertyError(GeofenceKey)
    
    /// Error, use_geofences in Configuration file is set to false.
    case CannotRequestGeofencesWhenDisabled
}

internal enum AnalyticsError: Int, ErrorType {
    static let domain = "AnalyticsError"
    
    case SendAnalyticsError = 5001
}

internal enum LocationError: Int, ErrorType {
    static let domain = "LocationError"
    
    case DownloadGeofencesError = 6001
}

