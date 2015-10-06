//
//  PhoenixOAuthTestCase.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import XCTest

@testable import PhoenixSDK

class PhoenixOAuthTestCase : XCTestCase {
    
    func testOAuthProvider() {
        
        let provider = PhoenixOAuthDefaultProvider()
        XCTAssert(provider.bestPasswordGrantOAuth.tokenType == provider.sdkUserOAuth.tokenType)
        provider.developerLoggedIn = true
        XCTAssert(provider.bestPasswordGrantOAuth.tokenType == provider.loggedInUserOAuth.tokenType)
        
        
    }
    
}