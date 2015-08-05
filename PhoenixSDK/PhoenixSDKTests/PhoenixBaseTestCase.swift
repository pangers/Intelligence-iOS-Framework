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
    
    typealias MockCallback = (()->Void)
    typealias MockResponse = (data:String?,statusCode:Int32,headers:[String:String]?)
    let tokenUrl = NSURL(string: "https://api.phoenixplatform.eu/identity/v1/oauth/token")!
    let tokenMethod = "POST"
    let anonymousTokenSuccessfulResponse = "{\"access_token\":\"1JJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let loggedInTokenSuccessfulResponse = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"refresh_token\":\"JJJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    
    override func setUp() {
        super.setUp()
        Injector.storage = MockSimpleStorage()
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: URL Mock
    
    func mockResponseForURL(url:NSURL!, method:String?, response:(data:String?,statusCode:Int32,headers:[String:String]?), callback:MockCallback? = nil) {
        mockResponseForURL(url, method: method, responses: [response], callbacks: [callback])
    }
    
    func mockResponseForURL(url:NSURL!, method:String?, responses:[MockResponse], callbacks: [MockCallback?]? = nil) {
        let count = responses.count
        var expectations = [(MockCallback?, MockResponse, XCTestExpectation)]()
        for i in 0..<count {
            expectations += [ (callbacks?[i], responses[i],
                expectationWithDescription("mock \(url) iteration \(i)")) ]
        }
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                if let method = method where method != request.HTTPMethod {
                    return false
                }
                return request.URL! == url
            },
            withStubResponse: { _ in
                // Fulfil a single expectation
                /*
                guard let (callback, response, expectation) = expectations.first else {
                    return OHHTTPStubsResponse(data: NSData(), statusCode: 0, headers: nil)
                }
                */
                let (callback, response, expectation) = expectations.first!
                expectations.removeAtIndex(0)
                // Execute callback before fulfilling expectation so we can chain multiple expectations together
                callback?()
                expectation.fulfill()
                let stubData = ((response.data) ?? "").dataUsingEncoding(NSUTF8StringEncoding)!
                return OHHTTPStubsResponse(data: stubData, statusCode:response.statusCode, headers:response.headers)
        })
    }
    
    // MARK: - Authentication Mock
    
    
    func mockAuthenticationResponse(response: MockResponse) {
        mockAuthenticationResponses([response])
    }
    
    func mockAuthenticationResponses(responses: [MockResponse]) {
        mockResponseForURL(tokenUrl, method: tokenMethod, responses: responses)
    }
    
    /// Mock the authentication response
    func mockResponseForAuthentication(statusCode:Int32, anonymous: Bool? = true, callback:MockCallback? = nil) {
        let responseData = (statusCode == 200) ? (anonymous == true ? anonymousTokenSuccessfulResponse : loggedInTokenSuccessfulResponse) : ""
        
        mockResponseForURL(tokenUrl,
            method: tokenMethod,
            response: (data:responseData, statusCode: statusCode, headers: nil),
            callback: callback)
    }
}