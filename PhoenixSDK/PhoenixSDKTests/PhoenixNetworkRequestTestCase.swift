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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /// Verify correct behaviour on token obtained
    func testTokenObtained() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        
        mockResponseForAuthentication(200)
        
        phoenix?.network.enqueueAuthenticationOperationIfRequired()
        
        // Test it's only called once.
        phoenix?.network.enqueueAuthenticationOperationIfRequired()
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkAuthenticated, "Phoenix is not authenticated after a successful response")
        }
    }
    
    /// Verify that there is a call executed when the token is available, but expired.
    func testTokenObtainedOnExpiredtoken() {
        // Mock that we have a token, but expired
        mockExpiredPhoenixOAuthStorage()
        XCTAssert(!checkAuthenticated, "Phoenix is not authenticated before a response")
        
        mockResponseForAuthentication(200)
        
        phoenix?.network.enqueueAuthenticationOperationIfRequired()
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkAuthenticated, "Phoenix is not authenticated after a successful response")
        }
    }

    
    /// Tests that an invalid JSON means no authentication obtained.
    func testAuthInvalidJSON() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        mockResponseForURL(tokenUrl, method: tokenMethod, response: (data: "Broken JSON\'!@£$%^&*}", statusCode: 200, headers:nil))
        
        phoenix?.network.enqueueAuthenticationOperationIfRequired()
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkAuthenticated, "Phoenix is not authenticated after a successful response")
        }
    }
    
    /// Mocks a 401 response in a request, and how the authentication is later scheduled
    func testEnqueueAuthorizationOn401Operation() {
        // Mock a valid authentication
        mockValidPhoenixOAuthStorage()
        
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
    
    /// Mocks a 403 response in the authentication request, and how the callback
    /// of the operation is later called with the error.
    func testAuthorization403CallsbackToRequestOperation() {
        let url = NSURL(string: "http://www.google.com/")!
        
        mockResponseForAuthentication(403)
        assertURLNotCalled(url, method: "GET")
        
        let expectation = expectationWithDescription("The request callback is called.")
        
        phoenix!.network.executeRequest(NSURLRequest(URL: url)) { (data, response, error) -> () in
            XCTAssertNotNil(error,"Nil error when a 403 was received in authentication")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
        }
    }
    
    /// Mocks a 401 response in the authentication request, and how the callback
    /// of the operation is later called with the error.
    func testAuthorization401CallsbackToRequestOperation() {
        let url = NSURL(string: "http://www.google.com/")!
        
        mockResponseForAuthentication(403)
        assertURLNotCalled(url, method: "GET")
        
        let expectation = expectationWithDescription("The request callback is called.")
        
        phoenix!.network.executeRequest(NSURLRequest(URL: url)) { (data, response, error) -> () in
            XCTAssertNotNil(error,"Nil error when a 403 was received in authentication")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
        }
    }
    
    /// Mocks a 403 response in a request, and how the authentication is later scheduled
    func testEnqueueAuthorizationOn403Operation() {
        // Mock a valid authentication
        mockValidPhoenixOAuthStorage()
        
        let url = NSURL(string: "http://www.google.com/")!
        
        mockResponseForURL(url,
            method: "GET",
            response: (data:"", statusCode: 403, headers: nil))
        phoenix!.network.executeRequest(NSURLRequest(URL: url)) { (data, response, error) -> () in
            XCTAssert(response?.statusCode == 403)
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
        }
    }
    
    /// Verifies that upon a request operation, we get as output the correct
    /// values obtained in the network.
    func testNetworkRequestOperation() {
        let initialRequest = NSURLRequest(URL: NSURL(string: "http://www.google.com/")!)
        let stringData = "Hola"
        let expectation = expectationWithDescription("")
        let statusCode = Int32(200)
        let op = PhoenixSDK.PhoenixNetworkRequestOperation(withSession: NSURLSession.sharedSession(), request: initialRequest, authentication: PhoenixSDK.Phoenix.Authentication(withPhoenixOAuthStorage: storage))
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
        let expectationOperation = expectationWithDescription("Operation")
        let requestExpectation = expectationWithDescription("Request")
        
        mockResponseForAuthentication(200, callback: {
            self.mockResponseForURL(initialRequest.URL!, method: nil, response: (stringData, statusCode, nil), callback: nil, expectation: requestExpectation)
        })

        // Force Invalidate tokens
        mockExpiredPhoenixOAuthStorage()
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
        
        phoenix?.network.enqueueAuthenticationOperationIfRequired()
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkAuthenticated, "Phoenix is authenticated Despite the response being a 401")
        }
    }

    /// Testig 404 on token request:
    func testToken404Obtained() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        mockResponseForAuthentication(404)
        
        phoenix?.network.enqueueAuthenticationOperationIfRequired()
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkAuthenticated, "Phoenix is authenticated Despite the response being a 404")
        }
    }

    /// Testig 403 on token request:
    func testToken403Obtained() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        mockResponseForAuthentication(403)
        
        phoenix?.network.enqueueAuthenticationOperationIfRequired()
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(!self.checkAuthenticated, "Phoenix is authenticated Despite the response being a 404")
        }
    }
    
}

