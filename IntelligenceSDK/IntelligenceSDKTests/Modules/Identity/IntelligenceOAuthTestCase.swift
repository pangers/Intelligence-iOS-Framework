//
//  IntelligenceOAuthTestCase.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import XCTest

@testable import IntelligenceSDK

class IntelligenceOAuthTestCase : XCTestCase {
    
    func testOAuthProvider() {
        
        let provider = IntelligenceOAuthDefaultProvider()
        XCTAssert(provider.bestPasswordGrantOAuth.tokenType == provider.sdkUserOAuth.tokenType)
        provider.developerLoggedIn = true
        XCTAssert(provider.bestPasswordGrantOAuth.tokenType == provider.loggedInUserOAuth.tokenType)
        
        provider.sdkUserOAuth.password = "TEST"
        provider.sdkUserOAuth.accessToken = nil
        provider.sdkUserOAuth.refreshToken = nil
        provider.sdkUserOAuth.userId = nil
        provider.sdkUserOAuth.username = nil
        
        XCTAssertFalse(provider.sdkUserOAuth.isAuthenticated())
        provider.sdkUserOAuth.accessToken = "TEST"
        XCTAssertFalse(provider.sdkUserOAuth.isAuthenticated())
        provider.sdkUserOAuth.refreshToken = "TEST"
        
        XCTAssert(provider.sdkUserOAuth.isAuthenticated())
        
        XCTAssertFalse(provider.applicationOAuth.isAuthenticated())
        provider.applicationOAuth.accessToken = "TEST"
        XCTAssert(provider.applicationOAuth.isAuthenticated())
        
        provider.sdkUserOAuth.store()
    }
    
}