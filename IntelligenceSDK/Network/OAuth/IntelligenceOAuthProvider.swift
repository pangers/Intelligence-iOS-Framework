//
//  IntelligenceOAuthProvider.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

protocol IntelligenceOAuthProvider {
    var applicationOAuth: IntelligenceOAuthProtocol { get set }
//    var sdkUserOAuth: IntelligenceOAuthProtocol { get set }
    var loggedInUserOAuth: IntelligenceOAuthProtocol { get set }
    var bestPasswordGrantOAuth: IntelligenceOAuthProtocol { get }
    var developerLoggedIn: Bool { get set }
}

final class IntelligenceOAuthDefaultProvider: IntelligenceOAuthProvider {

    /// grant_type 'client_credentials' OAuth type.
    var applicationOAuth: IntelligenceOAuthProtocol = IntelligenceOAuth(tokenType: .application)

    /// grant_type 'password' OAuth types.
//    var sdkUserOAuth: IntelligenceOAuthProtocol = IntelligenceOAuth(tokenType: .sdkUser)
    var loggedInUserOAuth: IntelligenceOAuthProtocol = IntelligenceOAuth(tokenType: .loggedInUser)

    /// Best OAuth we have for grant_type 'password'.
    var bestPasswordGrantOAuth: IntelligenceOAuthProtocol {
        return  applicationOAuth
        //return developerLoggedIn ? loggedInUserOAuth : sdkUserOAuth
    }

    var developerLoggedIn = false
}
