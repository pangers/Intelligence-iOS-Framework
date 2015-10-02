//
//  TokenStorage.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

// MARK:- Constants

internal let OAuthUsernameKey = "username"
internal let OAuthUserIdKey = "userId"
internal let OAuthPasswordKey = "password"
internal let OAuthAccessTokenKey = "access_token"
internal let OAuthRefreshTokenKey = "refresh_token"

// TODO: Rename this class!

/// The protocol to implement in order to become a simple storage.
@objc internal protocol TokenStorage {
    
    // Basic subscript implementation
    subscript(index: String) -> AnyObject? {get set}
    
}

/// A protocol extension to provide a wrapper over any class implementing
/// simple storage that provides the required values used by the app.
internal extension TokenStorage {
    
    var username: String? {
        get {
            return self[OAuthUsernameKey] as? String
        }
        set {
            self[OAuthUsernameKey] = newValue
        }
    }
    
    var password: String? {
        get {
            return self[OAuthPasswordKey] as? String
        }
        set {
            self[OAuthPasswordKey] = newValue
        }
    }
    
    var accessToken:String? {
        get {
            return self[OAuthAccessTokenKey] as? String
        }
        set {
            self[OAuthAccessTokenKey] = newValue
        }
    }
    
    var refreshToken:String? {
        get {
            return self[OAuthRefreshTokenKey] as? String
        }
        set {
            self[OAuthRefreshTokenKey] = newValue
        }
    }
    
    var userId:Int? {
        get {
            return self[OAuthUserIdKey] as? Int
        }
        set {
            self[OAuthUserIdKey] = newValue
        }
    }
    
}
