//
//  MockOAuthProvider.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class MockOAuthProvider: PhoenixOAuthProvider {
    /// grant_type 'client_credentials' OAuth type.
    internal var applicationOAuth: PhoenixOAuthProtocol
    
    /// grant_type 'password' OAuth types.
    internal var sdkUserOAuth: PhoenixOAuthProtocol
    internal var loggedInUserOAuth: PhoenixOAuthProtocol
    
    /// Best OAuth we have for grant_type 'password'.
    internal var bestPasswordGrantOAuth: PhoenixOAuthProtocol {
        return developerLoggedIn ? loggedInUserOAuth : sdkUserOAuth
    }
    internal var developerLoggedIn = false
    
    init() {
        applicationOAuth = PhoenixOAuth(tokenType: .Application, storage: MockSimpleStorage())
        sdkUserOAuth = PhoenixOAuth(tokenType: .SDKUser, storage: MockSimpleStorage())
        loggedInUserOAuth = PhoenixOAuth(tokenType: .LoggedInUser, storage: MockSimpleStorage())
    }
    
    func reset() {
        reset(sdkUserOAuth)
        reset(applicationOAuth)
        reset(loggedInUserOAuth)
    }
    
    func reset(var oauth: PhoenixOAuthProtocol) {
        PhoenixOAuth.reset(oauth)
        if oauth.tokenType == .LoggedInUser {
            developerLoggedIn = false
        }
    }
}