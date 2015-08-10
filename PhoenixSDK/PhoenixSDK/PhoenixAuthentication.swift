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
    
    /// Returns: Boolean indicating whether or not we need to authenticate in the current state in order to retrieve tokens.
    var requiresAuthentication: Bool { get }
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
    final class Authentication: PhoenixAuthenticationProtocol {

        // MARK: Instance variables
        
        private var storage: TokenStorage
        
        var requiresAuthentication: Bool {
            return accessToken == nil
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
                storage.accessToken = newValue
            }
        }
        
        // MARK: Initializers

        /// Default initializer
        /// - Parameter tokenStorage: Where to store access tokens.
        init(withTokenStorage tokenStorage:TokenStorage) {
            storage = tokenStorage
        }
        
        // MARK: Functions
        
        /// Clear our current access token, should occur when 401/403 is received.
        func clearAccessToken() {
            // Refresh token may still be valid but access token has expired
            accessToken = nil
        }
        
        /// Reset to a clean-slate.
        func reset() {
            if storage is PhoenixKeychain {
                // Remove keychain elements.
                (storage as! PhoenixKeychain).erase()
            } else {
                // Tests need to execute differently.
                clearAccessToken()
            }
        }
    }
}
