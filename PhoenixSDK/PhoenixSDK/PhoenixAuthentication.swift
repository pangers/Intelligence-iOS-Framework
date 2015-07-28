//
//  PhoenixAuthentication.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

extension Phoenix {
    class Authentication {
        private let accessTokenKey = "access_token"
        private let expiresInKey = "expires_in"
        private let refreshTokenKey = "refresh_token"
        
        /// Create new instance using JSON.
        init?(json: JSONDictionary) {
            guard let token = json[accessTokenKey] as? String,
                expire = json[expiresInKey] as? Double where token.isEmpty == false && expire > 0 else {
                    // TODO: Fail invalid response, retry?
                    print("Invalid response")
                    return
            }
            if let token = json[refreshTokenKey] as? String {
                // Optionally returned by server (only for 'password' grant type?)
                refreshToken = token
            }
            // TODO: Store expiration date as NSTimeInterval (timeSinceReferenceDate)
            accessTokenExpirationDate = NSDate(timeInterval: expire, sinceDate: NSDate())
            accessToken = token
        }
        
        /// Expiry date of access token.
        private var accessTokenExpirationDate: NSDate?
        
        /// Return if current date is later than expiry date.
        private var accessTokenExpired: Bool {
            return NSDate().timeIntervalSinceReferenceDate > accessTokenExpirationDate?.timeIntervalSinceReferenceDate ?? 0
        }
        
        /// Access token used in OAuth bearer header for requests.
        var accessToken: String? {
            didSet {
                // TODO: Store access token
                if accessToken == nil || accessToken!.isEmpty {
                    accessTokenExpirationDate = nil
                }
            }
        }
        
        /// Refresh token used in requests to retrieve a new access token.
        var refreshToken: String? {
            didSet {
                // TODO: Store refresh token
            }
        }
        
        /// Boolean indicating whether or not we need to authenticate in the current state in order to retrieve tokens.
        var requiresAuthentication: Bool {
            return accessToken != nil ? accessTokenExpired : true
        }
        
        /// Returns false if username and password are set, otherwise true.
        var anonymous: Bool {
            return !(username != nil && password != nil && username!.isEmpty == false && password!.isEmpty == false)
        }
        
        /// Set username for OAuth authentication with credentials.
        var username: String?
        
        /// Set password for OAuth authentication with credentials.
        var password: String?
        
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