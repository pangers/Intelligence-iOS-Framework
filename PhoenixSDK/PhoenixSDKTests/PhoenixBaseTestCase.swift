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

class PhoenixDelegateTest: PhoenixDelegate {
    private var creation = false, login = false, role = false
    init(
        expectCreationFailed: Bool = false,
        expectLoginFailed: Bool = false,
        expectRoleFailed: Bool = false)
    {
        creation = expectCreationFailed
        login = expectLoginFailed
        role = expectRoleFailed
    }
    
    
    @objc func userCreationFailedForPhoenix(phoenix: Phoenix) {
        XCTAssertTrue(creation)
    }
    
    @objc func userLoginRequiredForPhoenix(phoenix: Phoenix) {
        XCTAssertTrue(login)
    }
    
    @objc func userRoleAssignmentFailedForPhoenix(phoenix: Phoenix) {
        XCTAssertTrue(role)
    }
}


class PhoenixBaseTestCase : XCTestCase {
    
    let mockClientCredentialsOAuth = PhoenixOAuth(tokenType: .Application, storage: MockSimpleStorage())
    let mockPasswordOAuth = PhoenixOAuth(tokenType: .SDKUser, storage: MockSimpleStorage())
    let mockLoginOAuth = PhoenixOAuth(tokenType: .LoggedInUser, storage: MockSimpleStorage())
    
    typealias MockCallback = (()->Void)
    typealias MockResponse = (data:String?,statusCode:Int32,headers:[String:String]?)
    let tokenUrl = NSURL(string: "https://api.phoenixplatform.eu/identity/v1/oauth/token")!
    let tokenMethod = "POST"
    let anonymousTokenSuccessfulResponse = "{\"access_token\":\"1JJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let loggedInTokenSuccessfulResponse = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"refresh_token\":\"JJJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    var storage = MockSimpleStorage()
    var configuration: Phoenix.Configuration!
    var phoenix: Phoenix!
    
    var isAuthenticated: Bool = false
    var isLoggedIn: Bool = false
    
    override func setUp() {
        super.setUp()
        do {
            try self.configuration = PhoenixSDK.Phoenix.Configuration(fromFile: "config", inBundle:NSBundle(forClass: PhoenixNetworkRequestTestCase.self))
            self.configuration!.region = .Europe
            
            let tester = PhoenixDelegateTest(expectCreationFailed: false, expectLoginFailed: false, expectRoleFailed: false)
            
            try self.phoenix = Phoenix(withDelegate: tester, configuration: configuration, oauthStorage: storage)
            
            let expectation = expectationWithDescription("Expectation")
            
            
            
            mockResponseForAuthentication(200, true)
            mockResponseForAuthentication(200, false)
            
            
            self.phoenix.startup({ (success) -> () in
                if success {
                    expectation.fulfill()
                } else {
                    XCTFail("Startup failed!")
                }
            })
        }
        catch {
        }
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
        phoenix = nil
        configuration = nil
    }
    
    // MARK: URL Mock
    
    func mockResponseForURL(url:NSURL!, method:String?, response:(data:String?,statusCode:Int32,headers:[String:String]?), expectation: XCTestExpectation? = nil, callback:MockCallback? = nil) {
        mockResponseForURL(url, method: method, responses: [response], callbacks: [callback], expectations: [expectation])
    }
    
    func mockResponseForURL(url:NSURL!, method:String?, responses:[MockResponse], callbacks: [MockCallback?]? = nil, expectations:[XCTestExpectation?]? = nil) {
        let count = responses.count
        var runs = [(MockCallback?, MockResponse, XCTestExpectation)]()
        for i in 0..<count {
            runs += [ (callbacks?[i], responses[i], expectations?[i] ??
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
                let (callback, response, expectation) = runs.first!
                runs.removeAtIndex(0)
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