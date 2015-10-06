//
//  PhoenixOAuth.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

enum PhoenixOAuthTokenType: String {
    case Application = "ApplicationUser"
    case SDKUser = "SDKUser"
    case LoggedInUser = "LoggedInUser"
}

/// This class supports the PhoenixOAuthPipeline
internal class PhoenixOAuth {
    
    let tokenType: PhoenixOAuthTokenType
    var accessToken: String?
    var refreshToken: String?
    var username: String?
    
    /// Password will be stored in Keychain for SDKUser
    /// And in memory only for LoggedInUser
    var password: String?
    
    convenience init(tokenType: PhoenixOAuthTokenType) {
        self.init(tokenType:tokenType, tokenStorage:PhoenixKeychain(account: tokenType.rawValue))
    }
    
    init(tokenType:PhoenixOAuthTokenType, tokenStorage:TokenStorage) {
        self.tokenType = tokenType
        let keychain = tokenStorage
        accessToken = keychain.accessToken
        
        // Application User only has 'accessToken' they don't care about refresh tokens.
        if tokenType != .Application {
            // SDKUser and LoggedInUser have 'username'
            refreshToken = keychain.refreshToken
            username = keychain.username
            if tokenType == .SDKUser {
                // SDKUser also has a 'password'
                password = keychain.password
            }
        }
    }
    
    func isAuthenticated() -> Bool {
        if accessToken == nil { return false }
        if tokenType != .Application {
            if refreshToken == nil { return false }
        }
        return true
    }
    
    class func reset(tokenType: PhoenixOAuthTokenType) {
        let keychain = PhoenixKeychain(account: tokenType.rawValue)
        keychain.accessToken = nil
        keychain.refreshToken = nil
        keychain.username = nil
        keychain.password = nil
    }
    
    func updateCredentials(withUsername username: String, password: String) {
        assert(tokenType != .Application, "Invalid method for Application tokens")
        self.username = username
        self.password = password
    }
    
    func updateWithResponse(response: JSONDictionary?) -> Bool {
        guard let updatedAccessToken = response?[OAuthAccessTokenKey] as? String else {
            return false
        }
        accessToken = updatedAccessToken
        if tokenType != .Application {
            // We also require a refresh token
            guard let updatedRefreshToken = response?[OAuthRefreshTokenKey] as? String else {
                return false
            }
            refreshToken = updatedRefreshToken
        }
        store()
        return true
    }
    
    private func store() {
        let keychain = PhoenixKeychain(account: tokenType.rawValue)
        assert(accessToken != nil)
        keychain.accessToken = accessToken
        if tokenType != .Application {
            // Assert we have required information.
            assert(refreshToken != nil && username != nil)
            keychain.refreshToken = refreshToken
            keychain.username = username
            if tokenType == .SDKUser {
                // Only store SDKUser passwords.
                assert(password != nil)
                keychain.password = password
            }
        }
    }
}