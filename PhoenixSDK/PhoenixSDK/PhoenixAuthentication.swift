//
//  PhoenixAuthentication.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

extension Phoenix {
    
    /// Authentication class provides a wrapper over Phoenix's authentication responses.
    public class Authentication {

        // MARK: Constants
        
        // Constants to parse the JSON object
        private let accessTokenKey = "access_token"
        private let expiresInKey = "expires_in"
        private let refreshTokenKey = "refresh_token"
        private let phoenixDefaults = PhoenixDefaults.phoenixDefaults()
        
        // MARK: Instance variables
        
        /// Set username for OAuth authentication with credentials.
        var username: String?
        
        /// Set password for OAuth authentication with credentials.
        var password: String?
        
        /// The access token used in OAuth bearer header for requests.
        var accessToken: String? {
            get {
                // If access token has expired, return nil
                if accessTokenExpirationDate == nil {
                    self.accessToken = nil
                    return nil
                }
                guard let token = phoenixDefaults.pd_get(accessTokenKey) as? String else {
                    self.accessToken = nil
                    return nil
                }
                return token
            }
            set {
                // If access token is invalid, clear expiry
                if newValue == nil || newValue!.isEmpty {
                    accessTokenExpirationDate = nil
                }
                phoenixDefaults.pd_set(newValue, forKey: accessTokenKey)
            }
        }
        
        /// Refresh token used in requests to retrieve a new access token.
        var refreshToken: String? {
            get {
                return phoenixDefaults.pd_get(refreshTokenKey) as? String
            }
            set {
                phoenixDefaults.pd_set(newValue, forKey: refreshTokenKey)
            }
        }
        
        /// Expiry date of access token.
        private var accessTokenExpirationDate: NSDate? {
            get {
                guard let seconds = phoenixDefaults.pd_get(expiresInKey) as? Double else {
                    return nil
                }
                let date = NSDate(timeIntervalSinceReferenceDate: seconds)
                // Only return valid expiration date if it is not expired
                if NSDate().earlierDate(date) == date {
                    self.accessTokenExpirationDate = nil
                    return nil
                }
                return date
            }
            set {
                phoenixDefaults.pd_set(newValue?.timeIntervalSinceReferenceDate, forKey: expiresInKey)
            }
        }
        
        /// Boolean indicating whether or not we need to authenticate in the current state in order to retrieve tokens.
        var requiresAuthentication: Bool {
            return accessToken == nil
        }
        
        /// Returns false if username and password are set, otherwise true.
        var anonymous: Bool {
            return !(username != nil && password != nil && username!.isEmpty == false && password!.isEmpty == false)
        }
        
        // MARK: Initializers

        /// - Parameter json: The JSONDictionary to load the access from.
        /// - Returns: an optional Authentication object depending on whether the authentication
        /// could be extracted from the JSONDictionary received.
        init?(json: JSONDictionary) {

            guard let token = json[accessTokenKey] as? String,
                expire = json[expiresInKey] as? Double
                where !token.isEmpty && expire > 0 else {
                    return nil
            }

            accessTokenExpirationDate = NSDate(timeInterval: expire, sinceDate: NSDate())
            accessToken = token

            // Load optional refresh token. Optionally returned by server (only for 'password' grant type?)
            guard let unwrappedRefreshToken = json[refreshTokenKey] as? String else {
                return
            }
            
            refreshToken = unwrappedRefreshToken
        }
        
        init?() {
            if accessTokenExpirationDate == nil || accessToken?.isEmpty == true {
                return nil
            }
        }
        
        // MARK: Functions
        
        /// Expire our current access token, should occur when 401 is received.
        func expireAccessToken() {
            // Refresh token may still be valid but access token has expired
            accessToken = nil
        }
        
        /// Expire both tokens, should occur when 403 is received.
        func invalidateTokens() {
            // Refresh token is invalid
            refreshToken = nil
            // Need to reauthenticate using credentials
            accessToken = nil
        }
    }
}


class PhoenixDefaults: NSUserDefaults {
    class func phoenixDefaults() -> PhoenixDefaults {
        return PhoenixDefaults(suiteName: "PhoenixSDK")!
    }
    func pd_set(value: AnyObject?, forKey key: String) {
        if value == nil {
            removeObjectForKey(key)
        } else {
            // Treat empty values the same as nil
            if let str = value as? String where str.isEmpty {
                setObject(nil, forKey: key)
            } else {
                setObject(value, forKey: key)
            }
        }
    }
    func pd_get(key: String) -> AnyObject? {
        return valueForKey(key)
    }
}
