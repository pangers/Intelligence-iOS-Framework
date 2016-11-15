//
//  MockOAuthProvider.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK

let applicationAccessToken = "1JJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0"
let userAccessToken = "OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0"
let userRefreshToken = "JJJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0"

let mockCompanyID = 1
let mockUserID = 6016
let mockUsername = "username"
let mockPassword = "Pas5w0rd5"
let mockFirstName = "Firstname"
let mockLastName = "Surname"
let mockAvatarURL = "http://tigerspike.com"

class MockOAuthProvider: IntelligenceOAuthProvider {
    
    /// grant_type 'client_credentials' OAuth type.
    internal var applicationOAuth: IntelligenceOAuthProtocol
    
    /// grant_type 'password' OAuth types.
    internal var sdkUserOAuth: IntelligenceOAuthProtocol
    internal var loggedInUserOAuth: IntelligenceOAuthProtocol
    
    /// Best OAuth we have for grant_type 'password'.
    internal var bestPasswordGrantOAuth: IntelligenceOAuthProtocol {
        return developerLoggedIn ? loggedInUserOAuth : sdkUserOAuth
    }
    internal var developerLoggedIn = false
    
    init() {
        applicationOAuth = IntelligenceOAuth(tokenType: .Application, storage: MockSimpleStorage())
        sdkUserOAuth = IntelligenceOAuth(tokenType: .SDKUser, storage: MockSimpleStorage())
        loggedInUserOAuth = IntelligenceOAuth(tokenType: .LoggedInUser, storage: MockSimpleStorage())
    }
    
    func fakeAccessToken(var oauth: IntelligenceOAuthProtocol) {
        oauth.accessToken = applicationAccessToken
    }
    
    func fakeLoggedIn(var oauth: IntelligenceOAuthProtocol, fakeUser: Intelligence.User) {
        oauth.username = fakeUser.username
        oauth.password = fakeUser.password
        oauth.userId = fakeUser.userId
        oauth.refreshToken = userRefreshToken
        oauth.accessToken = userAccessToken
        if oauth.tokenType == .LoggedInUser {
            developerLoggedIn = true
        }
    }
    
    func reset() {
        reset(sdkUserOAuth)
        reset(applicationOAuth)
        reset(loggedInUserOAuth)
    }
    
    func reset(var oauth: IntelligenceOAuthProtocol) {
        IntelligenceOAuth.reset(oauth)
        if oauth.tokenType == .LoggedInUser {
            developerLoggedIn = false
        }
    }
    
    func isAuthenticated() -> Bool {
        return true
    }
    
    func updateCredentials(withUsername username: String, password: String) {
        
    }
    
    func updateWithResponse(response: JSONDictionary?) -> Bool {
        return true
    }
    
    func store() {
        
    }
}