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

    let tokenUrl = NSURL(string: "https://api.phoenixplatform.eu/identity/v1/oauth/token")!
    let tokenMethod = "POST"
    let anonymousTokenSuccessfulResponse = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let loggedInTokenSuccessfulResponse = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"refresh_token\":\"JJJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"

    override func setUp() {
        super.setUp()
        Injector.storage = MockSimpleStorage()
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    typealias MockResponse = (data:String?,statusCode:Int32,headers:[String:String]?)
    let tokenUrl = NSURL(string: "https://api.phoenixplatform.eu/identity/v1/oauth/token")!
    let tokenMethod = "POST"
    let anonymousTokenSuccessfulResponse = "{\"access_token\":\"1JJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let loggedInTokenSuccessfulResponse = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"refresh_token\":\"JJJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    
    // MARK: Helpers
    
    func mockResponsesForAuthentication(responses: [MockResponse]) {
        mockResponseForURL(tokenUrl, method: tokenMethod, responses: responses)
    }
    
    func mockResponseForAuthentication(statusCode:Int32, anonymous: Bool? = true) {
        let responseData = (statusCode == 200) ?
            (anonymous == true ? anonymousTokenSuccessfulResponse : loggedInTokenSuccessfulResponse) : ""
        mockResponseForURL(tokenUrl, method: tokenMethod, responses: [(responseData, statusCode, nil)])
    }
    
    func mockResponseForURL(url:NSURL!, method:String?, responses:[MockResponse]) {
        let count = responses.count
        var expectations = [(MockResponse, XCTestExpectation)]()
        for i in 0..<count {
            expectations += [ (responses[i], expectationWithDescription("mock \(url) iteration \(i)")) ]
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
                let (response, expectation) = expectations.first!
                expectations.removeAtIndex(0)
                expectation.fulfill()
                let stubData = ((response.data) ?? "").dataUsingEncoding(NSUTF8StringEncoding)!
                return OHHTTPStubsResponse(data: stubData, statusCode:response.statusCode, headers:response.headers)
            })
    }
    
    func mockResponseForURL(url:NSURL!, method:String?, response:(data:String?,statusCode:Int32,headers:[String:String]?) ) {
        mockResponseForURL(url, method: method, responses: [response])
    }
    
    /// Mock the authentication response
    func mockResponseForAuthentication(statusCode:Int32, anonymous: Bool? = true, expectation:XCTestExpectation? = nil) {
        let responseData = (statusCode == 200) ? (anonymous == true ? anonymousTokenSuccessfulResponse : loggedInTokenSuccessfulResponse) : ""
        
        mockResponseForURL(tokenUrl,
            method: tokenMethod,
            response: (data:responseData, statusCode: statusCode, headers: nil),
            expectation:expectation)
    }

}