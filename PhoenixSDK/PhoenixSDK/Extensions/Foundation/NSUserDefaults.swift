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
    
    func pd_setRefreshToken(value: String?) {
        self[refreshTokenKey] = value
    }
    
    func pd_refreshToken() -> String? {
        return self[refreshTokenKey] as? String
    }
    
    func pd_setAccessToken(value: String?) {
        self[accessTokenKey] = value
    }
    
    func pd_accessToken() -> String? {
        return self[accessTokenKey] as? String
    }
    
    func pd_setTokenExpirationDate(value: NSDate?) {
        pd_setDate(value, forKey: tokenExpirationKey)
    }
    
    func pd_tokenExpirationDate() -> NSDate? {
        return pd_dateForKey(tokenExpirationKey)
    }
    
    
    func pd_setDate(value:NSDate?, forKey key:String) {
        guard let date = value else {
            self[key] = nil
            return
        }
        
        self[key] = date.timeIntervalSince1970
    }
    
    func pd_dateForKey(key:String) -> NSDate? {
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
                return;
            }
            
            setObject(value, forKey: index)
        }
    }
}
