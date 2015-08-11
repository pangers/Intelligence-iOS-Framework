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
        
        XCTAssert(Phoenix.Authentication(withJSON: wrongJsonDictionary, tokenStorage:storage) == nil, "Authentication obtained when passing a wrong dictionary")
        XCTAssert(Phoenix.Authentication(withJSON: emptyJsonDictionary, tokenStorage:storage) == nil, "Authentication obtained when passing a correct dictionary with empty values")
        XCTAssert(Phoenix.Authentication(withJSON: correctJsonDictionary, tokenStorage:storage) != nil, "No Authentication obtained when passing a correct dictionary")
        XCTAssert(Phoenix.Authentication(withJSON: correctWithRefreshTokenJsonDictionary, tokenStorage:storage) != nil, "No Authentication obtained when passing a correct dictionary with all the values")
    }
    
    func testInitializeAuthenticationParsedValues() {
        guard let authentication = Phoenix.Authentication(withJSON: correctWithRefreshTokenJsonDictionary, tokenStorage:storage) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }
        XCTAssert(authentication.accessToken == accessToken, "Access token stored correctly")
    }

    func testExpireAuthentication() {
        guard let authentication = Phoenix.Authentication(withJSON: correctWithRefreshTokenJsonDictionary, tokenStorage:storage) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }
        mockExpiredTokenStorage()
        XCTAssert(authentication.accessTokenExpirationDate == nil, "Access token is not expired")
        XCTAssert(authentication.requiresAuthentication, "Authorization is not expired")
    }

    func testExpireAuthenticationByTime() {
        var dictionary = correctWithRefreshTokenJsonDictionary
        dictionary["expires_in"] = Double(0.001)
        
        guard let authentication = Phoenix.Authentication(withJSON: dictionary, tokenStorage:storage) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }

        XCTAssert(!authentication.requiresAuthentication, "Initially requires authentication")

        // Sleep for 0.1 seconds.
        usleep(100000)
        
        XCTAssert(authentication.requiresAuthentication, "Does not require authentication")
    }

    
    func testInvalidateAuthentication() {
        guard let authentication = Phoenix.Authentication(withJSON: correctWithRefreshTokenJsonDictionary, tokenStorage:storage) else {
            XCTAssert(false, "Didn't acquire an authentication")
            return
        }
        
        authentication.accessToken = nil
        authentication.accessTokenExpirationDate = nil
        XCTAssert(authentication.accessToken == nil, "Access token is not expired")
        XCTAssert(authentication.requiresAuthentication, "Authorization is not expired")
    }

}
