//
//  IntelligenceOAuthStorage.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

// MARK: - Constants

let OAuthUsernameKey = "username"
let OAuthUserIdKey = "userId"
let OAuthPasswordKey = "password"
let OAuthAccessTokenKey = "access_token"
let OAuthRefreshTokenKey = "refresh_token"

// TODO: Rename this class!

/// The protocol to implement in order to become a simple storage.
@objc protocol IntelligenceOAuthStorage {

    // Basic subscript implementation
    subscript(index: String) -> Any? {get set}

}

/// A protocol extension to provide a wrapper over any class implementing
/// simple storage that provides the required values used by the app.
extension IntelligenceOAuthStorage {

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

    var accessToken: String? {
        get {
            return self[OAuthAccessTokenKey] as? String
        }
        set {
            self[OAuthAccessTokenKey] = newValue
        }
    }

    var refreshToken: String? {
        get {
            return self[OAuthRefreshTokenKey] as? String
        }
        set {
            self[OAuthRefreshTokenKey] = newValue
        }
    }

    var userId: Int? {
        get {
            return self[OAuthUserIdKey] as? Int
        }
        set {
            self[OAuthUserIdKey] = newValue
        }
    }

}
