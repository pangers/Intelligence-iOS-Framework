//
//  PhoenixBaseTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
@testable import PhoenixSDK

import OHHTTPStubs

class PhoenixBaseTestCase : XCTestCase {

    typealias MockResponse = (data:String?,statusCode:Int32,headers:[String:String]?)

    let tokenUrl = NSURL(string: "https://api.phoenixplatform.eu/identity/v1/oauth/token")!
    let tokenMethod = "POST"
    let anonymousTokenSuccessfulResponse = "{\"access_token\":\"anonymousToken\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let loggedInTokenSuccessfulResponse = "{\"access_token\":\"loggedInToken\",\"refresh_token\":\"JJJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"

    override func setUp() {
        super.setUp()
        Injector.storage = MockSimpleStorage()
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK:- Authentication mock Helpers
    
    /// Mock authentication with a set of responses
    func mockResponsesForAuthentication(responses: [MockResponse]) {
        mockResponseForURL(tokenUrl, method: tokenMethod, responses: responses)
    }

    /// Mock the authentication response
    func mockResponseForAuthentication(statusCode:Int32, anonymous: Bool? = true, callback:(()->Void)? = nil) {
        let successResponse = (anonymous == true) ? anonymousTokenSuccessfulResponse : loggedInTokenSuccessfulResponse
        let responseData = (statusCode == 200) ? successResponse : ""
        
        mockResponseForURL(tokenUrl,
            method: tokenMethod,
            response: (data:responseData, statusCode: statusCode, headers: nil),
            callback: callback)
    }
    
    // MARK:- Generic mock Helpers

    /// Mocks a response for a given URL.
    func mockResponseForURL(url:NSURL!, method:String?, response:(data:String?,statusCode:Int32,headers:[String:String]?), expectation:XCTestExpectation? = nil, callback:(()->Void)? = nil) {
        if let expectation = expectation {
            mockResponseForURL(url, method: method, responses: [response],expectations:[expectation], callback:callback)
        }
        else {
            mockResponseForURL(url, method: method, responses: [response], callback:callback)
        }
    }

    /// Mocks an array of responses for a given URL being requested.
    func mockResponseForURL(url:NSURL!, method:String?, responses:[MockResponse], callback:(()->Void)? = nil) {
        let count = responses.count
        var expectations = [XCTestExpectation]()
        for i in 0..<count {
            expectations += [ expectationWithDescription("mock \(url) iteration \(i)") ]
        }
        
        mockResponseForURL(url, method: method, responses:responses, expectations:expectations, callback:callback)
    }

    /// Mocks an array of responses for a given URL being requested.
    func mockResponseForURL(url:NSURL!, method:String?, responses:[MockResponse], expectations:[XCTestExpectation], callback:(()->Void)? = nil) {
        // Assert the count
        assert(expectations.count == responses.count)

        var responsesArray = responses
        var expectationsArray = expectations
        
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                if let method = method where method != request.HTTPMethod {
                    return false
                }
                return request.URL! == url
            },
            withStubResponse: { _ in
                XCTAssertFalse(expectationsArray.isEmpty,"Received more requests than expected.")
                
                // Before fulfilling an expectation, call the callback so another one can be created, and thus chained.
                callback?()
                
                let response = responsesArray.removeAtIndex(0)
                let expectation = expectationsArray.removeAtIndex(0)

                // Fulfil a single expectation
                expectation.fulfill()

                // Provide the response
                let stubData = ((response.data) ?? "").dataUsingEncoding(NSUTF8StringEncoding)!
                return OHHTTPStubsResponse(data: stubData, statusCode:response.statusCode, headers:response.headers)
        })
    }
    
    // MARK:- Assertions
    
    func assertURLNotCalled(url:NSURL, method:String? = "GET") {
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                if let method = method where method != request.HTTPMethod {
                    return false
                }
                
                XCTAssertFalse(request.URL! == url,"URL \(url) was called.")
                return false
            },
            withStubResponse: { _ in
                return OHHTTPStubsResponse() // Never reached
        })
    }

}