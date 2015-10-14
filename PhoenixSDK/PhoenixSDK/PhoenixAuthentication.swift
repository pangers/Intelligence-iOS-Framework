//
//  PhoenixAuthentication.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// The authentication protocol. Defines the variables that need to be provided by
/// Authentication.
internal protocol PhoenixAuthenticationProtocol {
    /// The id for the logged in user.
    var userId: Int? { get set }
    
    /// The access token used in OAuth bearer header for requests.
    var accessToken: String? { get set }
    
    /// The expiration date of the access token.
    var accessTokenExpirationDate: NSDate? { get set }
}

internal extension Phoenix {

    /// Authentication class holds the token and authentication data of Phoenix,
    /// and also handles the JSON responses of the identity module, reading and
    /// storing the data it requires to identify the user later on.
    ///
    /// Relies on the TokenStorage passed to store and load
    /// the tokens. The default Phoenix storage is PhoenixKeychain. The developer
    /// can override the TokenStorage protocol and provide a different implementation,
    /// such as storing it in CoreData, a file, NSUserDefaults,...
    internal final class Authentication: PhoenixAuthenticationProtocol {

        // MARK: Instance variables
        
        private var storage: TokenStorage
        
        var requiresAuthentication: Bool {
            guard let _ = accessToken, _ = accessTokenExpirationDate else {
                return true
            }
            return false
        }
        
        var userId: Int? {
            get {
                return storage.userId
            }
            set {
                storage.userId = newValue
            }
        }
        
        var accessToken: String? {
            get {
                return storage.accessToken
            }
            set {
                // If access token is invalid, clear expiry
                if newValue == nil || newValue!.isEmpty {
                    accessTokenExpirationDate = nil
                }
                storage.accessToken = newValue
            }
        }

        var accessTokenExpirationDate: NSDate? {
            get {
                let date = storage.tokenExpirationDate
                
                // Only return valid expiration date if it is not expired
                if date?.timeIntervalSinceNow <= 0 {
                    self.accessTokenExpirationDate = nil
                    return nil
                }
                
                return date
            }
            set {
                storage.tokenExpirationDate = newValue
            }
        }

        // MARK: Initializers

        /// Default initializer
        /// - Parameter tokenStorage: Where to store access tokens.
        init(withTokenStorage tokenStorage:TokenStorage) {
            storage = tokenStorage
        }
        
        /// Convenience initializer
        /// - Parameter withJSON: JSON file to attempt to get access token information from.
        /// - Parameter tokenStorage: Where to store access tokens.
        convenience init?(withJSON json: JSONDictionary, tokenStorage: TokenStorage) {
            self.init(withTokenStorage: tokenStorage)
            if update(withJSON: json) == false {
                return nil
            }
        }
        
        // MARK: Functions
        
        /// Update access token and expiration date.
        func update(withJSON json: JSONDictionary?) -> Bool {
            guard let token = json?[accessTokenKey] as? String,
                expire = json?[expiresInKey] as? Double
                where !token.isEmpty && expire > 0 else {
                    return false
            }
            accessTokenExpirationDate = NSDate(timeIntervalSinceNow: expire)
            accessToken = token
            return true
        }
        
        /// Clear our current access token, should occur when 401 is received.
        func clearAccessToken() {
            // Refresh token may still be valid but access token has expired
            accessToken = nil
            accessTokenExpirationDate = nil
        }
        
        /// Reset to a clean-slate.
        func reset() {
            if let storage = storage as? PhoenixKeychain {
                // Remove keychain elements.
                storage.userId = nil
                storage.accessToken = nil
                storage.tokenExpirationDate = nil
            } else {
                // Tests need to execute differently.
                clearAccessToken()
            }
        }
    }
}
