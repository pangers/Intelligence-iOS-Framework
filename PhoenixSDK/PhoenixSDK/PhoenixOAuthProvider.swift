//
//  PhoenixOAuthProvider.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal protocol PhoenixOAuthProvider {
    var applicationOAuth: PhoenixOAuth { get set }
    var sdkUserOAuth: PhoenixOAuth { get set }
    var loggedInUserOAuth: PhoenixOAuth { get set }
    var bestPasswordGrantOAuth: PhoenixOAuth { get }
    var developerLoggedIn: Bool { get set }
}

internal final class PhoenixOAuthDefaultProvider: PhoenixOAuthProvider {
    
    /// grant_type 'client_credentials' OAuth type.
    internal var applicationOAuth = PhoenixOAuth(tokenType: .Application)
    
    /// grant_type 'password' OAuth types.
    internal var sdkUserOAuth = PhoenixOAuth(tokenType: .SDKUser)
    internal var loggedInUserOAuth = PhoenixOAuth(tokenType: .LoggedInUser)
    
    /// Best OAuth we have for grant_type 'password'.
    internal var bestPasswordGrantOAuth: PhoenixOAuth {
        return developerLoggedIn ? loggedInUserOAuth : sdkUserOAuth
    }
    internal var developerLoggedIn = false
    
}
