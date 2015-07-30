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

protocol SimpleStorage {
    
    // Subscript implementation
    subscript(index: String) -> AnyObject? {get set}
    
}

extension SimpleStorage {
    
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
