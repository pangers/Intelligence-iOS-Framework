//
//  PhoenixNetworkRequest.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixNetworkRequestTestCase : PhoenixBaseTestCase {
    let expectationTimeout:NSTimeInterval = 3
    
    var phoenix:Phoenix?
    var configuration:Phoenix.Configuration?
    
    var checkAuthenticated: Bool {
        return self.phoenix?.isAuthenticated ?? false
    }
    var checkLoggedIn: Bool {
        return self.phoenix?.isLoggedIn ?? false
    }
    
    override func setUp() {
        super.setUp()
        do {
            try self.configuration = PhoenixSDK.Phoenix.Configuration(fromFile: "config", inBundle:NSBundle(forClass: PhoenixNetworkRequestTestCase.self))
            self.configuration!.region = .Europe
            try self.phoenix = Phoenix(withConfiguration: configuration!)
        }
        catch {
        }
    }
    
    override func tearDown() {
        super.tearDown()
        phoenix = nil
        configuration = nil
    }
    
    /// Verify correct behaviour on token obtained
    func testTokenObtained() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        
        mockResponseForAuthentication(200)
        
        let expectation = expectationWithDescription("Started up")
        phoenix?.startup(withCallback: { (authenticated) -> () in
            XCTAssert(authenticated == true)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(self.checkAuthenticated, "Phoenix is not authenticated after a successful response")
        }
    }
    
    /// Verify correct behaviour on token obtained
    func testLoginTokenObtained() {
        XCTAssert(!self.phoenix!.isLoggedIn, "Phoenix is authenticated before a response")
        
        mockResponseForAuthentication(200, anonymous: false)
        
        let expectation = expectationWithDescription("logged in")
        phoenix?.login(withUsername: "username", password: "password") { (authenticated) -> () in
            XCTAssert(authenticated == true)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(self.checkLoggedIn, "Phoenix is not authenticated after a successful response")
        }
    }
    
    /// Verifies that when trying to do a request, an authorization with 'grant_type=password' will be fired if it is needed.
    func testEnqueueAuthorizationLoginOnNewOperation() {
        let initialRequest = NSURLRequest(URL: NSURL(string: "http://www.google.com/")!)
        let stringData = "Hola"
        let statusCode = Int32(200)
        let expectationOperation = expectationWithDescription("")
        phoenix!.network.authentication.configure(withUsername: "username", password: "password")
        
        mockResponseForURL(initialRequest.URL!, method: nil, response: (data: stringData, statusCode: statusCode, headers: nil))
        mockResponseForAuthentication(200, anonymous: false)
        
        phoenix!.network.executeRequest(initialRequest) { (data, response, error) -> () in
            expectationOperation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(self.phoenix!.isLoggedIn, "Phoenix is not authenticated after a successful response")
        }
    }
    
    /// Verifies that when trying to do a request, an authorization with 'grant_type=refresh_token' will be fired if it is needed.
    func testEnqueueAuthorizationRefreshTokenOnNewOperation() {
        let initialRequest = NSURLRequest(URL: NSURL(string: "http://www.google.com/")!)
        let stringData = "Hola"
        let statusCode = Int32(200)
        let expectationOperation = expectationWithDescription("")
        phoenix!.network.authentication.configure(withUsername: "username", password: "password")
        Injector.storage.accessToken = "Somevalue"
        Injector.storage.refreshToken = "Somevalue"
        Injector.storage.tokenExpirationDate = NSDate(timeIntervalSinceNow: -10)
        
        mockResponseForURL(initialRequest.URL!, method: nil, response: (data: stringData, statusCode: statusCode, headers: nil))
        mockResponseForAuthentication(200, anonymous: false)
        
        phoenix!.network.executeRequest(initialRequest) { (data, response, error) -> () in
            expectationOperation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(self.phoenix!.isLoggedIn, "Phoenix is not authenticated after a successful response")
        }
    }
    
    
    /// Verify that there is a call executed when the token is available, but expired.
    func testTokenObtainedOnExpiredtoken() {
        // Mock using the injector storage that we have a token, but expired
        Injector.storage.accessToken = "Somevalue"
        Injector.storage.refreshToken = ""
        Injector.storage.tokenExpirationDate = NSDate(timeIntervalSinceNow: -10)
        
        XCTAssert(!checkAuthenticated, "Phoenix is not authenticated before a response")
        
        mockResponseForAuthentication(200)
        
        let expectation = expectationWithDescription("Started up")
        phoenix?.startup(withCallback: { (authenticated) -> () in
            XCTAssert(authenticated == true)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(self.checkAuthenticated, "Phoenix is authenticated after a successful response")
        }
    }

    
    /// Verify that we logout clearing our tokens successfully when anonymously logged in.
    func testAnonymousLogout() {
        // Mock using the injector storage that we have a token
        Injector.storage.accessToken = "Somevalue"
        Injector.storage.refreshToken = ""
        Injector.storage.tokenExpirationDate = NSDate(timeIntervalSinceNow: 10)
        XCTAssert(checkAuthenticated, "Phoenix is authenticated before a response")
        
        phoenix?.logout()
        XCTAssert(!checkAuthenticated, "Phoenix is not authenticated after a successful response")
    }

    /// Verify correct behaviour on logout when logged in with username and password.
    func testLoginLogoutTokenCleared() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        
        mockResponseForAuthentication(200, anonymous: false)
        
        let expectation = expectationWithDescription("Logged in and out")
        phoenix?.login(withUsername: "username", password: "password") { (authenticated) -> () in
            XCTAssert(authenticated == true)
            self.phoenix?.logout()
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkLoggedIn, "Phoenix is authenticated after a logout")
        }
    }
    
    
    /// Verify if a user logs out, then logs in anonymously (triggered by a request being added to the queue) 
    /// that the access_token does not match the previous one.
    func testLoginLogoutAnonymousLoginTokenComparison() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        
        // Create expectation for login...
        
        let responses = [MockResponse(loggedInTokenSuccessfulResponse, 200, nil),
            MockResponse(anonymousTokenSuccessfulResponse, 200, nil)]
        mockResponsesForAuthentication(responses)
        
        let initialRequest = NSURLRequest(URL: NSURL(string: "http://www.google.com/")!)
        let stringData = "Hola"
        let statusCode = Int32(200)
        // We're logged out, lets enqeuue a generic request to force enqueue an anonymous login
        mockResponseForURL(initialRequest.URL!, method: nil, response: (data: stringData, statusCode: statusCode, headers: nil))
        
        let expectation = expectationWithDescription("login-logout-google-anonymous-login expectation")
        phoenix?.login(withUsername: "username", password: "password") { (authenticated) -> () in
            // Ensure we're logged in...
            XCTAssert(authenticated == true, "Method should return authenticated = true")
            
            // Store token for use later
            let loggedInToken = self.phoenix?.network.authentication.accessToken
            
            // Logout...
            self.phoenix?.logout()
            XCTAssert(self.phoenix?.isLoggedIn == false, "Phoenix should be logged out")
            
            // Execute google request to enqueue authentication
            self.phoenix?.network.executeRequest(initialRequest, callback: { (data, response, error) -> () in
                XCTAssert(self.phoenix?.network.authentication.accessToken != loggedInToken, "Tokens match")
                expectation.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(self.checkAuthenticated == true, "Phoenix is authenticated after a login-logout-anonymouslogin")
        }
    }
    
    /// Tests that an invalid JSON means no authentication obtained.
    func testAuthInvalidJSON() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        mockResponseForURL(tokenUrl, method: tokenMethod, response: (data: "Broken JSON\'!@£$%^&*}", statusCode: 200, headers:nil))
        
        phoenix?.startup(withCallback: { (authenticated) -> () in
        })
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkAuthenticated, "Phoenix is not authenticated after a successful response")
        }
    }
    
    /// Mocks a 401 response in a request, and how the authentication is later scheduled
    func testEnqueueAuthorizationOn401Operation() {
        // Mock a valid authentication
        Injector.storage.accessToken = "Something"
        Injector.storage.refreshToken = "Something"
        Injector.storage.tokenExpirationDate = NSDate(timeIntervalSinceNow: 10000)
        
        let url = NSURL(string: "http://www.google.com/")!
        
        mockResponseForURL(url,
            method: "GET",
            response: (data:"", statusCode: 401, headers: nil))
        mockResponseForAuthentication(200)
        
        var didReceiveNetworkError = false
        
        phoenix!.network.executeRequest(NSURLRequest(URL: url)) { (data, response, error) -> () in
            if response?.statusCode == 401 {
                didReceiveNetworkError = true
            }
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
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
        
        let url = NSURL(string: "http://www.google.com/")!
        
        mockResponseForURL(url,
            method: "GET",
            response: (data:"", statusCode: 403, headers: nil))
        mockResponseForAuthentication(200)
        
        var didReceiveNetworkError = false
        
        phoenix!.network.executeRequest(NSURLRequest(URL: url)) { (data, response, error) -> () in
            if response?.statusCode == 403 {
                didReceiveNetworkError = true
            }
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
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
        let op = PhoenixSDK.PhoenixNetworkRequestOperation(withSession: NSURLSession.sharedSession(), withRequest: initialRequest, withAuthentication: PhoenixSDK.Phoenix.Authentication())
        op.completionBlock = {
            expectation.fulfill()
            let (data, response) = op.output!
            XCTAssert(data == stringData.dataUsingEncoding(NSUTF8StringEncoding), "Unexpected data")
            XCTAssert(response?.statusCode == Int(statusCode), "Unexpected status code")
        }
        
        // Mock the response and perform the call
        mockResponseForURL(initialRequest.URL!, method: "GET", response: (data: stringData, statusCode: statusCode, headers: nil))
        NSOperationQueue().addOperation(op)
        
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
        }
    }

    /// Verifies that when trying to do a request, an authorization will be fired if it is needed.
    func testEnqueueAuthorizationOnNewOperation() {
        let initialRequest = NSURLRequest(URL: NSURL(string: "http://www.google.com/")!)
        let stringData = "Hola"
        let statusCode = Int32(200)
        let expectationOperation = expectationWithDescription("")
        
        mockResponseForURL(initialRequest.URL!, method: nil, response: (data: stringData, statusCode: statusCode, headers: nil))
        mockResponseForAuthentication(200)

        // Force Invalidate tokens
        PhoenixSDK.Phoenix.Authentication().invalidateTokens()
        phoenix!.network.executeRequest(initialRequest) { (data, response, error) -> () in
            expectationOperation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(self.checkAuthenticated, "Phoenix is not authenticated after a successful response")
        }
    }
    
    
    /// Testig 401 on token request:
    func testToken401Obtained() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        
        mockResponseForAuthentication(401)
        phoenix?.startup(withCallback: { (authenticated) -> () in
            XCTAssert(authenticated == false)
        })
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkAuthenticated, "Phoenix is authenticated Despite the response being a 401")
        }
    }

    /// Testig 404 on token request:
    func testToken404Obtained() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        mockResponseForAuthentication(404)
        
        phoenix?.startup(withCallback: { (authenticated) -> () in
            XCTAssert(authenticated == false)
        })
        
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkAuthenticated, "Phoenix is authenticated Despite the response being a 404")
        }
    }

    /// Testig 403 on token request:
    func testToken403Obtained() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        mockResponseForAuthentication(403)
        
        phoenix?.startup(withCallback: { (authenticated) -> () in
            XCTAssert(authenticated == false)
        })
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkAuthenticated, "Phoenix is authenticated Despite the response being a 404")
        }
    }
}

