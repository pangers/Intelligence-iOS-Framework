//
//  PhoenixAuthenticationTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 28/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixAuthenticationTestCase: PhoenixBaseTestCase {
    
    private let correctWithRefreshTokenJsonDictionary = [
        "access_token" : "123",
        "expires_in" : 100.0,
        "refresh_token" : "123"
    ]
    
    let refreshToken = "123"
    let accessToken = "123"
    
    let username = "123"
    let password = "123"
    
    func testInitializeOptionalAuthentication() {
        let wrongJsonDictionary = ["wrong":"Dictionary"]
        let emptyJsonDictionary = [
            "access_token" : "",
            "expires_in" : 0.0
        ]
        
        let correctJsonDictionary = [
            "access_token" : "123",
            "expires_in" : 100.0
        ]
        
        XCTAssert(Phoenix.Authentication(json: wrongJsonDictionary, withTokenStorage:storage) == nil, "Authentication obtained when passing a wrong dictionary")
        XCTAssert(Phoenix.Authentication(json: emptyJsonDictionary, withTokenStorage:storage) == nil, "Authentication obtained when passing a correct dictionary with empty values")
        XCTAssert(Phoenix.Authentication(json: correctJsonDictionary, withTokenStorage:storage) != nil, "No Authentication obtained when passing a correct dictionary")
        XCTAssert(Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary, withTokenStorage:storage) != nil, "No Authentication obtained when passing a correct dictionary with all the values")
        XCTAssert(Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary, withTokenStorage:storage)?.anonymous == true, "The authentication appears to be non anonymous")
    }

    func testUsernameAndPasswordStoredValues() {
        guard let authentication = Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary, withTokenStorage:storage) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }
        
        authentication.username = username
        authentication.password = password
        
        XCTAssert(authentication.username == username, "Username stored correctly")
        XCTAssert(authentication.password == password, "Password stored correctly")
    }
    
    func testInitializeAuthenticationParsedValues() {
        guard let authentication = Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary, withTokenStorage:storage) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }
        
        XCTAssert(authentication.refreshToken == refreshToken, "Refresh token stored correctly")
        XCTAssert(authentication.accessToken == accessToken, "Access token stored correctly")
    }

    func testExpireAuthentication() {
        guard let authentication = Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary, withTokenStorage:storage) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }
        
        authentication.expireAccessToken()
        XCTAssert(authentication.accessToken == nil, "Access token is not expired")
        XCTAssert(authentication.requiresAuthentication, "Authorization is not expired")
    }

    func testExpireAuthenticationByTime() {
        var dictionary = correctWithRefreshTokenJsonDictionary
        dictionary["expires_in"] = Double(0.001)
        
        guard let authentication = Phoenix.Authentication(json: dictionary, withTokenStorage:storage) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }

        XCTAssert(!authentication.requiresAuthentication, "Initially requires authentication")

        // Sleep for 0.1 seconds.
        usleep(100000)
        
        XCTAssert(authentication.requiresAuthentication, "Does not require authentication")
    }

    
    func testInvalidateAuthentication() {
        guard let authentication = Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary, withTokenStorage:storage) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }
        
        authentication.invalidateTokens()
        XCTAssert(authentication.refreshToken == nil, "Refresh token is not expired")
        XCTAssert(authentication.accessToken == nil, "Access token is not expired")
        XCTAssert(authentication.requiresAuthentication, "Authorization is not expired")
    }

}
