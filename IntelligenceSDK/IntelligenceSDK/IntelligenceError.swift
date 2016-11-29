//
//  IntelligenceError.swift
//  IntelligenceSDK
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
        let domain = Bundle(for: Intelligence.self).bundleIdentifier!
        let userInfo : [String : Any]?
        
        if let httpStatusCode = httpStatusCode {
            userInfo = [HTTPStatusCodeNSErrorUserInfoKey: httpStatusCode]
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
/// the initial setup of Intelligence's configuration.
/// Refer to the Readme file to obtain further instructions on setup.
@objc public enum ConfigurationError: Int, Error {
    /// Configuration file does not exist.
    case fileNotFoundError = 1001
    
    /// A property is invalid.
    case invalidPropertyError
    
    /// Configuration file is invalid
    /// (Couldn't parse into a JSON or had an issue while reading it)
    case invalidFileError
    
    /// There is a missing property in the configuration.
    case missingPropertyError
}

/// Enumeration to list the errors that can occur in any request.
@objc public enum RequestError: Int, Error {
    /// Error to return when parsing JSON fails.
    case parseError = 2001
    
    /// Error to return if user doesn't have access to a particular API.
    case accessDeniedError
    
    /// Error to return if user is offline.
    case internetOfflineError
    
    /// Error to return if the user is not authenticated.
    case unauthorized
    
    /// Error to return if the user's role does not grant them access to this method.
    case forbidden
    
    /// Error to return if an error occurs that we can not handle.
    case unhandledError
}

/// Enumeration to list the errors that can occur in the authentication module.
@objc public enum AuthenticationError: Int, Error {
    /// The client or user credentials are incorrect.
    case credentialError = 3001
    
    /// The account has been disabled.
    case accountDisabledError
    
    /// The account has been locked due to multiple authentication failures.
    /// An Administration is required to unlock.
    case accountLockedError
    
    /// The token is invalid or has expired.
    case tokenInvalidOrExpired
}

/// Enumeration to list the errors that can occur in the identity module.
@objc public enum IdentityError: Int, Error {
    /// The user is invalid.
    case invalidUserError = 4001
    
    /// The password provided is too weak. See `Intelligence.User` password field to see
    /// the security requirements of the password.
    case weakPasswordError
    
    /// The device token is invalid (zero length).
    case deviceTokenInvalidError
    
    /// Device token has not been registered yet.
    case deviceTokenNotRegisteredError
}

/// Enumeration to list the errors that can occur in the installation module
internal enum InstallationError: Int, Error {
    /// Called 'create' method unnecessarily.
    case alreadyInstalledError = 5001
    
    /// Called 'update' method unnecessarily.
    case alreadyUpdatedError
}

/// These are internal errors thrown by the Geofence class.
internal enum GeofenceError: Error {
    
    /// Error to return when we have a property error. Internal use only.
    case invalidPropertyError(GeofenceKey)
}

/// These are internal errors thrown by the Analytics class.
internal enum AnalyticsError: Int, Error {
    /// Request contains outdated events.
    case oldEventsError = 6001
}

