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

protocol PhoenixOAuthProtocol {
    var storage: PhoenixOAuthStorage { get set }
    var tokenType: PhoenixOAuthTokenType { get set }
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    var username: String? { get set }
    var userId: Int? { get set }
    
    /// Password will be stored in Keychain for SDKUser and in memory only for LoggedInUser
    /// for the duration of the login method (cleared afterwards).
    var password: String? { get set }

    func isAuthenticated() -> Bool
    func updateCredentials(withUsername username: String, password: String)
    func updateWithResponse(response: JSONDictionary?) -> Bool
    func store()
}


/// This class supports the PhoenixOAuthPipeline
internal class PhoenixOAuth: PhoenixOAuthProtocol {
    
    var storage: PhoenixOAuthStorage
    var tokenType: PhoenixOAuthTokenType
    var accessToken: String?
    var refreshToken: String?
    var username: String?
    var userId: Int?
    var password: String?
    
    init(tokenType: PhoenixOAuthTokenType, storage: PhoenixOAuthStorage? = nil) {
        self.tokenType = tokenType
        self.storage = storage ?? PhoenixKeychain(account: tokenType.rawValue)
        accessToken = self.storage.accessToken
        // Application User only has 'accessToken' they don't care about refresh tokens.
        if tokenType != .Application {
            // SDKUser and LoggedInUser have 'username', 'refreshToken' and optionally 'userId'
            refreshToken = self.storage.refreshToken
            username = self.storage.username
            userId = self.storage.userId
            if tokenType == .SDKUser {
                // SDKUser also has a 'password'
                password = self.storage.password
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
    
    class func reset(var oauth: PhoenixOAuthProtocol) {
        oauth.accessToken = nil
        oauth.refreshToken = nil
        oauth.username = nil
        oauth.password = nil
        oauth.userId = nil
        oauth.store()
    }
    
    func updateCredentials(withUsername username: String, password: String) {
        assert(tokenType != .Application, "Invalid method for Application tokens")
        self.username = username
        self.password = password
        // Reset userId, could be a different server but same username
        self.userId = nil
        store()
    }
    
    func updateWithResponse(response: JSONDictionary?) -> Bool {
        // This method is only called by login and refreshToken
        // Validate is not handled (refreshToken is optional for validate).
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
    
    func store() {
        storage.accessToken = accessToken
        if tokenType != .Application {
            // Assert we have required information.
            storage.refreshToken = refreshToken
            storage.username = username
            storage.userId = userId
            if tokenType == .SDKUser {
                // Only store SDKUser passwords.
                storage.password = password
            }
        }
    }
}