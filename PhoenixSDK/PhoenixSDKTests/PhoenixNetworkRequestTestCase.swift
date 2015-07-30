//
//  PhoenixNetworkRequest.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import PhoenixSDK

class PhoenixNetworkRequestTestCase : PhoenixBaseTestCase {
    
    var phoenix:Phoenix?
    var configuration:Phoenix.Configuration?
    
    override func setUp() {
        super.setUp()
        
        do {
            try self.configuration = PhoenixSDK.Phoenix.Configuration(fromFile: "config", inBundle:NSBundle(forClass: PhoenixNetworkRequestTestCase.self))
            self.configuration!.region = .Europe
            try self.phoenix = Phoenix(withConfiguration: configuration!)
        }
        catch {
            // I'm happy.
        }
    }
    
    func testTokenObtained() {
        XCTAssert(!self.phoenix!.isAuthenticated, "Phoenix is authenticated before a response")
        
        let expectation = expectationWithDescription("")
        
        // Swift
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                return request.URL!.absoluteString.hasPrefix(self.configuration!.baseURL!.absoluteString) &&
                    request.HTTPMethod == "POST"
            }
            ,
            withStubResponse: { _ in
                let stubData = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        })
        
        self.phoenix!.tryLogin { (authenticated) -> () in
            XCTAssert(authenticated, "Failed to authenticate")
            print(authenticated)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            
            XCTAssert(self.phoenix!.isAuthenticated, "Phoenix is not authenticated after a successful response")
        }
    }
    
    func testAuthRetryOnNoTokenObtained() {
        XCTAssert(!self.phoenix!.isAuthenticated, "Phoenix is authenticated before a response")
        
        let expectation = expectationWithDescription("")
        var countRetries = 0
        var countCallbacks = 0
        
        // Swift
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                return request.URL!.absoluteString.hasPrefix(self.configuration!.baseURL!.absoluteString) &&
                    request.HTTPMethod == "POST"
            }
            ,
            withStubResponse: { _ in
                
                countRetries++
                
                // Wrong response to force the network to retry
                let stubData = "{}".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        })
        
        self.phoenix!.tryLogin { (authenticated) -> () in
            XCTAssert(!authenticated, "Authenticated without a response")
            countCallbacks++
            expectation.fulfill()
            
            XCTAssertEqual(countCallbacks, 1, "Perform either more than a single callback calls or none at all")
        }
        
        waitForExpectationsWithTimeout(10) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            
            XCTAssertEqual(countRetries, 1, "Single called fired.")
        }
    }
    
}

