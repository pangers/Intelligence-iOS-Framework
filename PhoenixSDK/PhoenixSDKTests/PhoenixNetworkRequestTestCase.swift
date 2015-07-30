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
    
    /// Verify correct behaviour on token obtained
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
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            
            XCTAssert(self.phoenix!.isAuthenticated, "Phoenix is not authenticated after a successful response")
        }
    }
    
    /// Verifies that upon no token obtained, there are no more retries, and the caller callback is performed
    func testAuthNoRetryOnNoTokenObtained() {
        XCTAssert(!self.phoenix!.isAuthenticated, "Phoenix is authenticated before a response")
        
        let expectation = expectationWithDescription("")
        var countRetries = 0
        var countCallbacks = 0
        
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

    /// Tests that an invalid JSON means no authentication obtained.
    func testAuthInvalidJSON() {
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
                let stubData = "{asdas==".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        })
        
        self.phoenix!.tryLogin { (authenticated) -> () in
            XCTAssert(!authenticated, "Failed to authenticate")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            
            XCTAssert(!self.phoenix!.isAuthenticated, "Phoenix is not authenticated after a successful response")
        }
    }
    
    /// Mocks a 401 response in a request, and how the authentication is later scheduled
    func testEnqueueAuthorizationOn401Operation() {
        // Mock a valid authentication
        Injector.storage.accessToken = "Something"
        Injector.storage.refreshToken = "Something"
        Injector.storage.tokenExpirationDate = NSDate(timeIntervalSinceNow: 10000)
        
        let initialRequest = NSURLRequest(URL: NSURL(string: "http://www.google.com/")!)
        let stringData = "{}"
        let statusCode = Int32(401)
        let expectationOperation = expectationWithDescription("")
        var didReceiveNetworkError = false
        
        // Install stubs
        OHHTTPStubs.stubRequestsPassingTest( { request in request.URL == initialRequest.URL } ) { _ in
            // Return 401
            return OHHTTPStubsResponse(data: stringData.dataUsingEncoding(NSUTF8StringEncoding)!, statusCode:statusCode, headers:nil)
        }
        
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                // Authentication interception
                return request.URL!.absoluteString.hasPrefix(self.configuration!.baseURL!.absoluteString) &&
                    request.HTTPMethod == "POST"
            }
            ,
            withStubResponse: { _ in
                expectationOperation.fulfill()
                // Give back a token
                let stubData = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        })
        
        phoenix!.network.executeRequest(initialRequest) { (data, response, error) -> () in
            if response?.statusCode == Int(statusCode) {
                didReceiveNetworkError = true
            }
        }
        
        waitForExpectationsWithTimeout(10) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(didReceiveNetworkError)
        }
    }
    
    /// Mocks a 403 response in a request, and how the authentication is later scheduled
    func testEnqueueAuthorizationOn403Operation() {
        // Mock a valid authentication
        Injector.storage.accessToken = "Something"
        Injector.storage.refreshToken = "Something"
        Injector.storage.tokenExpirationDate = NSDate(timeIntervalSinceNow: 10000)
        
        let initialRequest = NSURLRequest(URL: NSURL(string: "http://www.google.com/")!)
        let stringData = "{}"
        let statusCode = Int32(403)
        let expectationOperation = expectationWithDescription("")
        var didReceiveNetworkError = false
        
        // Install stubs
        OHHTTPStubs.stubRequestsPassingTest( { request in request.URL == initialRequest.URL } ) { _ in
            // Return 401
            return OHHTTPStubsResponse(data: stringData.dataUsingEncoding(NSUTF8StringEncoding)!, statusCode:statusCode, headers:nil)
        }
        
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                // Authentication interception
                return request.URL!.absoluteString.hasPrefix(self.configuration!.baseURL!.absoluteString) &&
                    request.HTTPMethod == "POST"
            }
            ,
            withStubResponse: { _ in
                expectationOperation.fulfill()
                // Give back a token
                let stubData = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        })
        
        phoenix!.network.executeRequest(initialRequest) { (data, response, error) -> () in
            if response?.statusCode == Int(statusCode) {
                didReceiveNetworkError = true
            }
        }
        
        waitForExpectationsWithTimeout(10) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(didReceiveNetworkError)
        }
    }

    /// Verifies that upon a request operation, we get as output the correct
    /// values obtained in the network.
    func testNetworkRequestOperation() {
        let initialRequest = NSURLRequest(URL: NSURL(string: "http://www.google.com/")!)
        let stringData = "Hola"
        let expectation = expectationWithDescription("")
        let statusCode = Int32(200)
        
        OHHTTPStubs.stubRequestsPassingTest( { $0.URL == initialRequest.URL } ) { _ in
            return OHHTTPStubsResponse(data: stringData.dataUsingEncoding(NSUTF8StringEncoding)!, statusCode:statusCode, headers:nil)
        }
        
        let op = PhoenixSDK.PhoenixNetworkRequestOperation(withSession: NSURLSession.sharedSession(), withRequest: initialRequest, withAuthentication: PhoenixSDK.Phoenix.Authentication())
        op.completionBlock = {
            expectation.fulfill()
            let (data, response) = op.output!
            XCTAssert(data == stringData.dataUsingEncoding(NSUTF8StringEncoding), "Unexpected data")
            XCTAssert(response?.statusCode == Int(statusCode), "Unexpected status code")
        }
        
        NSOperationQueue().addOperation(op)
        
        
        waitForExpectationsWithTimeout(10) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
        }
    }

    /// Verifies that when trying to do a request, an authorization will be fired if it is needed.
    func testEnqueueAuthorizationOnNewOperation() {
        let initialRequest = NSURLRequest(URL: NSURL(string: "http://www.google.com/")!)
        let stringData = "Hola"
        let statusCode = Int32(200)
        let expectationOperation = expectationWithDescription("")
        var didTryLogin = false
        
        // Install stubs
        OHHTTPStubs.stubRequestsPassingTest( { $0.URL == initialRequest.URL } ) { _ in
            return OHHTTPStubsResponse(data: stringData.dataUsingEncoding(NSUTF8StringEncoding)!, statusCode:statusCode, headers:nil)
        }
        
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                print(request.URL)
                return request.URL!.absoluteString.hasPrefix(self.configuration!.baseURL!.absoluteString) &&
                    request.HTTPMethod == "POST"
            }
            ,
            withStubResponse: { _ in
                didTryLogin = true
                let stubData = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}".dataUsingEncoding(NSUTF8StringEncoding)
                return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        })
        
        // Force Invalidate tokens
        PhoenixSDK.Phoenix.Authentication().invalidateTokens()
        phoenix!.network.executeRequest(initialRequest) { (data, response, error) -> () in
            expectationOperation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(didTryLogin, "The app didn't try to login")
            XCTAssert(self.phoenix!.isAuthenticated, "Phoenix is not authenticated after a successful response")
        }
    }
}

