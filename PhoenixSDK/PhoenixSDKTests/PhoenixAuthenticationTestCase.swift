//
//  PhoenixAuthenticationTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 28/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixAuthenticationTestCase: XCTestCase {
    
    private let correctWithRefreshTokenJsonDictionary = [
        "access_token" : "123",
        "expires_in" : 100.0,
        "refresh_token" : "123"
    ]
    
    let refreshToken = "123"
    let accessToken = "123"

    
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
        
        XCTAssert(Phoenix.Authentication(json: wrongJsonDictionary) == nil, "Authentication obtained when passing a wrong dictionary")
        XCTAssert(Phoenix.Authentication(json: emptyJsonDictionary) == nil, "Authentication obtained when passing a correct dictionary with empty values")
        XCTAssert(Phoenix.Authentication(json: correctJsonDictionary) != nil, "No Authentication obtained when passing a correct dictionary")
        XCTAssert(Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary) != nil, "No Authentication obtained when passing a correct dictionary with all the values")
        XCTAssert(Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary)?.anonymous == true, "The authentication appears to be non anonymous")
    }

    func testInitializeAuthenticationParsedValues() {
        guard let authentication = Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }
        
        XCTAssert(authentication.refreshToken == refreshToken, "Refresh token stored correctly")
        XCTAssert(authentication.accessToken == accessToken, "Access token stored correctly")
        XCTAssert(!authentication.accessTokenExpired, "Access token is unexpectedly expired")
    }

    func testExpireAuthentication() {
        guard let authentication = Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }
        
        authentication.expireAccessToken()
        XCTAssert(authentication.accessToken == nil, "Access token is not expired")
        XCTAssert(authentication.accessTokenExpired, "Access token is not expired")
        XCTAssert(authentication.requiresAuthentication, "Authorization is not expired")
    }
    
    func testInvalidateAuthentication() {
        guard let authentication = Phoenix.Authentication(json: correctWithRefreshTokenJsonDictionary) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }
        
        authentication.invalidateTokens()
        XCTAssert(authentication.accessToken == nil, "Access token is not expired")
        XCTAssert(authentication.refreshToken == nil, "Refresh token is not expired")
        XCTAssert(authentication.accessTokenExpired, "Access token is not expired")
        XCTAssert(authentication.requiresAuthentication, "Authorization is not expired")
    }

    
    func testExpireAuthenticationByTime() {
        var dictionary = correctWithRefreshTokenJsonDictionary
        dictionary["expires_in"] = Double(0.01)
        
        guard let authentication = Phoenix.Authentication(json: dictionary) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }

        XCTAssert(!authentication.accessTokenExpired, "Access token is expired initially")
        XCTAssert(!authentication.requiresAuthentication, "Initially requires authentication")

        // Sleep for 0.1 seconds.
        usleep(100000)
        
        XCTAssert(authentication.accessTokenExpired, "Access token is not expired")
        XCTAssert(authentication.requiresAuthentication, "Does not require authentication")
    }

}
