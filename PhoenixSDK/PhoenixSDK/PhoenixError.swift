//
//  PhoenixError.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// The key to use in an NSError userInfo dictionary to retrieve the HTTP status code
public let HTTPStatusCodeNSErrorUserInfoKey = "httpStatusCode"

/// NSError extension to standardise domain and httpStatusCode insertion/extraction
extension NSError {
    
    /// Convenience method to create an NSError with a code, and optionally a httpStatusCode.
    /// The domain will be set to the SDK's bundleIdentifier, and the httpStatusCode will be added as the userInfo.
    convenience init(code: Int, httpStatusCode: Int? = nil) {
        let domain = NSBundle(forClass: Phoenix.self).bundleIdentifier!
        
        let userInfo : [NSObject : AnyObject]?
        
        if httpStatusCode != nil {
            userInfo = [HTTPStatusCodeNSErrorUserInfoKey: httpStatusCode!]
        }
        else {
            userInfo = nil
        }
        
        self.init(domain: domain, code: code, userInfo: userInfo)
    }
    
    /// Retrieve the httpStatusCode from an NSError.
    /// Returns the code if it is in the userInfo in the style init(code:httpStatusCode:) added it, or nil if it is not.
    func httpStatusCode() -> Int? {
        if let userInfo = self.userInfo as? [String : Int] {
            return userInfo[HTTPStatusCodeNSErrorUserInfoKey]
        }
        
        return nil
    }
}

/// Enumeration that defines the possible errors that can occur during
/// the initial setup of Phoenix's configuration.
/// Refer to the Readme file to obtain further instructions on setup.
@objc public enum ConfigurationError: Int, ErrorType {
    /// Configuration file does not exist.
    case FileNotFoundError = 1001
    
    /// A property is invalid.
    case InvalidPropertyError
    
    /// Configuration file is invalid
    /// (Couldn't parse into a JSON or had an issue while reading it)
    case InvalidFileError
    
    /// There is a missing property in the configuration.
    case MissingPropertyError
}

/// Enumeration to list the errors that can occur in any request.
@objc public enum RequestError: Int, ErrorType {
    /// Error to return when parsing JSON fails.
    case ParseError = 2001
    
    /// Error to return if user doesn't have access to a particular API.
    case AccessDeniedError
    
    /// Error to return if user is offline.
    case InternetOfflineError
    
    /// Error to return if the user is not authenticated.
    case Unauthorized
    
    /// Error to return if the user's role does not grant them access to this method.
    case Forbidden
    
    /// Error to return if an error occurs that we can not handle.
    case UnhandledError
}

/// Enumeration to list the errors that can occur in the authentication module.
@objc public enum AuthenticationError: Int, ErrorType {
    /// The client or user credentials are incorrect.
    case CredentialError = 3001
    
    /// The account has been disabled.
    case AccountDisabledError
    
    /// The account has been locked due to multiple authentication failures.
    /// An Administration is required to unlock.
    case AccountLockedError
    
    /// The token is invalid or has expired.
    case TokenInvalidOrExpired
}

/// Enumeration to list the errors that can occur in the identity module.
@objc public enum IdentityError: Int, ErrorType {
    /// The user is invalid.
    case InvalidUserError = 4001
    
    /// The password provided is too weak. See `Phoenix.User` password field to see
    /// the security requirements of the password.
    case WeakPasswordError
    
    /// The device token is invalid (zero length).
    case DeviceTokenInvalidError
    
    /// Device token has not been registered yet.
    case DeviceTokenNotRegisteredError
}

/// Enumeration to list the errors that can occur in the installation module
internal enum InstallationError: Int, ErrorType {
    /// Called 'create' method unnecessarily.
    case AlreadyInstalledError = 5001
    
    /// Called 'update' method unnecessarily.
    case AlreadyUpdatedError
}

/// These are internal errors thrown by the Geofence class.
internal enum GeofenceError: ErrorType {
    
    /// Error to return when we have a property error. Internal use only.
    case InvalidPropertyError(GeofenceKey)
}

/// These are internal errors thrown by the Analytics class.
internal enum AnalyticsError: Int, ErrorType {
    /// Request contains outdated events.
    case OldEventsError = 6001
}

