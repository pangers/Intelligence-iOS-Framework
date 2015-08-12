//
//  TokenStorage.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

// MARK:- Constants

internal let userIdKey = "userId"
internal let tokenExpirationKey = "token_expiration_date"
internal let accessTokenKey = "access_token"
internal let expiresInKey = "expires_in"

/// The protocol to implement in order to become a simple storage.
@objc public protocol TokenStorage {
    
    // Basic subscript implementation
    subscript(index: String) -> AnyObject? {get set}
    
}

/// A protocol extension to provide a wrapper over any class implementing
/// simple storage that provides the required values used by the app.
extension TokenStorage {
    var userId: Int? {
        get {
            return self[userIdKey] as? Int
        }
        set {
            self[userIdKey] = newValue
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
