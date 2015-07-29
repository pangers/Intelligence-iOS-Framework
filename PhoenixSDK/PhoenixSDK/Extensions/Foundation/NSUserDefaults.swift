//
//  File.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 28/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

private let accessTokenKey = "access_token"
private let refreshTokenKey = "refresh_token"
private let tokenExpirationKey = "token_expiration_date"

extension NSUserDefaults {    
    
    func phx_setRefreshToken(value: String?) {
        self[refreshTokenKey] = value
    }
    
    func phx_refreshToken() -> String? {
        return self[refreshTokenKey] as? String
    }
    
    func phx_setAccessToken(value: String?) {
        self[accessTokenKey] = value
    }
    
    func phx_accessToken() -> String? {
        return self[accessTokenKey] as? String
    }
    
    func phx_setTokenExpirationDate(value: NSDate?) {
        phx_setDate(value, forKey: tokenExpirationKey)
    }
    
    func phx_tokenExpirationDate() -> NSDate? {
        return phx_dateForKey(tokenExpirationKey)
    }
    
    
    func phx_setDate(value:NSDate?, forKey key:String) {
        guard let date = value else {
            self[key] = nil
            return
        }
        
        self[key] = date.timeIntervalSince1970
    }
    
    func phx_dateForKey(key:String) -> NSDate? {
        guard let timeInterval = self[key] as? NSTimeInterval else {
            return nil
        }
        
        return NSDate(timeIntervalSince1970: timeInterval)
    }
    
    // Subscript implementation
    subscript(index: String) -> AnyObject? {
        get {
            // return an appropriate subscript value here
            return objectForKey(index)
        }
        set(newValue) {
            defer {
                synchronize()
            }
            
            // perform a suitable setting action here
            guard let value = newValue else {
                removeObjectForKey(index)
                return
            }
            
            setObject(value, forKey: index)
        }
    }
}
