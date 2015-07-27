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
        private var accessTokenExpirationDate: NSDate?
        private var accessTokenExpired: Bool {
            // Return if current date is later than expiry date
            return NSDate().timeIntervalSinceReferenceDate > accessTokenExpirationDate?.timeIntervalSinceReferenceDate ?? 0
        }
        private var _accessToken: String?
        
        var accessToken: String? {
            get {
                return _accessToken
            }
            set {
                if newValue == nil || newValue!.isEmpty {
                    accessTokenExpirationDate = nil
                }
                _accessToken = newValue
            }
            // TODO: Store access token
        }
        var anonymous: Bool {
            return !(username != nil && password != nil && username!.isEmpty == false && password!.isEmpty == false)
        }
        var username: String?
        var password: String?
        // TODO: Store refresh token
        var refreshToken: String?
        var requiresAuthentication: Bool {
            return accessToken != nil ? accessTokenExpired : true
        }
        func expiresIn(seconds: Double) {
            accessTokenExpirationDate = NSDate(timeInterval: seconds, sinceDate: NSDate())
            // TODO: Store expiration date as NSTimeInterval (timeSinceReferenceDate)
        }
        func expireAccessToken() {
            // Refresh token may still be valid but access token has expired
            accessToken = nil
        }
        func invalidateTokens() {
            // Refresh token is invalid
            refreshToken = nil
            // Need to reauthenticate using credentials
            accessToken = nil
        }
    }
}