//
//  PhoenixOAuthProvider.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal protocol PhoenixOAuthProvider {
    var applicationOAuth: PhoenixOAuthProtocol { get set }
    var sdkUserOAuth: PhoenixOAuthProtocol { get set }
    var loggedInUserOAuth: PhoenixOAuthProtocol { get set }
    var bestPasswordGrantOAuth: PhoenixOAuthProtocol { get }
    var developerLoggedIn: Bool { get set }
}

internal final class PhoenixOAuthDefaultProvider: PhoenixOAuthProvider {
    
    /// grant_type 'client_credentials' OAuth type.
    internal var applicationOAuth: PhoenixOAuthProtocol = PhoenixOAuth(tokenType: .Application)
    
    /// grant_type 'password' OAuth types.
    internal var sdkUserOAuth: PhoenixOAuthProtocol = PhoenixOAuth(tokenType: .SDKUser)
    internal var loggedInUserOAuth: PhoenixOAuthProtocol = PhoenixOAuth(tokenType: .LoggedInUser)
    
    /// Best OAuth we have for grant_type 'password'.
    internal var bestPasswordGrantOAuth: PhoenixOAuthProtocol {
        return developerLoggedIn ? loggedInUserOAuth : sdkUserOAuth
    }
    internal var developerLoggedIn = false
    
}
