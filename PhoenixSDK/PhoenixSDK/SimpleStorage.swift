//
//  SimpleStorage.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

private let accessTokenKey = "access_token"
private let refreshTokenKey = "refresh_token"
private let tokenExpirationKey = "token_expiration_date"
private let usernameKey = "username"
private let userIdKey = "userId"
private let passwordKey = "password"

/// The protocol to implement in order to become a simple storage.
internal protocol SimpleStorage {
    
    // Basic subscript implementation
    subscript(index: String) -> AnyObject? {get set}
    
}

/// A protocol extension to provide a wrapper over any class implementing
/// simple storage that provides the required values used by the app.
internal extension SimpleStorage {
    
    var userId: Int? {
        get {
            return self[userIdKey] as? Int
        }
        set {
            self[userIdKey] = newValue
        }
    }
    
    var username: String? {
        get {
            return self[usernameKey] as? String
        }
        set {
            self[usernameKey] = newValue
        }
    }
    
    var password: String? {
        get {
            return self[passwordKey] as? String
        }
        set {
            self[passwordKey] = newValue
        }
    }
    
    var refreshToken: String? {
        get {
            return self[refreshTokenKey] as? String
        }
        set {
            self[refreshTokenKey] = newValue
        }
    }
    
    var accessToken:String? {
        get {
            return self[accessTokenKey] as? String
        }
        set {
            self[accessTokenKey] = newValue
        }
    }
    
    var tokenExpirationDate:NSDate? {
        get {
            guard let timeInterval = self[tokenExpirationKey] as? NSTimeInterval else {
                return nil
            }
            
            return NSDate(timeIntervalSince1970: timeInterval)
        }
        set {
            guard let date = newValue else {
                self[tokenExpirationKey] = nil
                return
            }
            
            self[tokenExpirationKey] = date.timeIntervalSince1970
        }
    }
}
