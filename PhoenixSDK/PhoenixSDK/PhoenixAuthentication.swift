//
//  PhoenixAuthentication.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

// MARK: Constants

private let accessTokenKey = "access_token"
private let expiresInKey = "expires_in"
private let refreshTokenKey = "refresh_token"

internal protocol PhoenixAuthenticationProtocol {
    var username: String? { get set }
    var password: String? { get set }
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    var accessTokenExpirationDate: NSDate? { get set }
    
    func loadAuthorizationFromJSON(json: JSONDictionary) -> Bool
}


extension PhoenixAuthenticationProtocol {
    
    /// Returns: Boolean indicating whether or not we need to authenticate in the current state in order to retrieve tokens.
    var requiresAuthentication: Bool {
        guard let _ = accessToken, _ = accessTokenExpirationDate else {
            return true
        }
        return false
    }
    
    /// Returns false if username and password are set, otherwise true.
    var anonymous: Bool {
        guard let username = username, password = password where !username.isEmpty && !password.isEmpty else {
            return true
        }
        return false
    }
}


internal extension Phoenix {

    /// Authentication class holds the token and authentication data of Phoenix,
    /// and also handles the JSON responses of the identity module, reading and
    /// storing the data it requires to identify the user later on.
    ///
    /// Relies on the SimpleStorage found in the Injector object to store and load
    /// the tokens. The default Phoenix storage is NSUserDefaults. The developer
    /// can override the SimpleStorage protocol and provide a different implementation,
    /// such as storing it in CoreData, a file, keychain,...
    final class Authentication: PhoenixAuthenticationProtocol {

        // MARK: Instance variables
        
        /// Username for OAuth authentication with credentials.
        var username: String?
        
        /// Password for OAuth authentication with credentials.
        var password: String?
        
        /// The access token used in OAuth bearer header for requests.
        var accessToken: String? {
            get {
                return Injector.storage.accessToken
            }
            set {
                // If access token is invalid, clear expiry
                if newValue == nil || newValue!.isEmpty {
                    accessTokenExpirationDate = nil
                }
                Injector.storage.accessToken = newValue
            }
        }
        
        /// Refresh token used in requests to retrieve a new access token.
        var refreshToken: String? {
            get {
                return Injector.storage.refreshToken
            }
            set {
                Injector.storage.refreshToken = newValue
            }
        }
        
        /// Expiry date of access token.
        var accessTokenExpirationDate: NSDate? {
            get {
                let date = Injector.storage.tokenExpirationDate
                
                // Only return valid expiration date if it is not expired
                if date?.timeIntervalSinceNow <= 0 {
                    self.accessTokenExpirationDate = nil
                    return nil
                }
                
                return date
            }
            set {
                Injector.storage.tokenExpirationDate = newValue
            }
        }
        
        // MARK: Initializers

        /// Default initializer
        init() {
            // nop
        }
        
        /// - Parameter json: The JSONDictionary to load the access from.
        /// - Returns: an optional Authentication object depending on whether the authentication
        /// could be extracted from the JSONDictionary received.
        convenience init?(json: JSONDictionary) {
            self.init()
            if ( !loadAuthorizationFromJSON(json) ) {
                return nil
            }
        }
        
        // MARK: Functions
        
        /// Reads from the JSON document the authorization credentials.
        /// - Parameter json: The JSON dictionary as loaded from the authorization request.
        /// - Returns: true if the authorization credentials were properly read.
        func loadAuthorizationFromJSON(json: JSONDictionary) -> Bool {
            guard let token = json[accessTokenKey] as? String,
                expire = json[expiresInKey] as? Double
                where !token.isEmpty && expire > 0 else {
                    return false
            }
            
            accessTokenExpirationDate = NSDate(timeIntervalSinceNow: expire)
            accessToken = token
            
            // Load optional refresh token. Optionally returned by server (only for 'password' grant type?)
            if let unwrappedRefreshToken = json[refreshTokenKey] as? String {
                refreshToken = unwrappedRefreshToken
            }
            
            return true
        }
        
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
        
        /// Configure with username and password.
        func configure(withUsername username: String, password: String) {
            invalidateTokens()
            self.username = username
            self.password = password
        }
        
        /// Reset to a clean-slate.
        func reset() {
            username = nil
            password = nil
            invalidateTokens()
        }
    }
}
