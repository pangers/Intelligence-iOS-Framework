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
    
    let expectationTimeout:NSTimeInterval = 5
    
    typealias MockCallback = (()->Void)
    typealias MockResponse = (data:String?,statusCode:Int32,headers:[String:String]?)
    
    var mockOAuthProvider: MockOAuthProvider!
    var mockDelegateWrapper: MockPhoenixDelegateWrapper!
    var mockNetwork: Network!
    var mockConfiguration: Phoenix.Configuration!
    var phoenix: Phoenix!
    var mockInstallationStorage = InstallationStorage()
    var mockInstallation: Phoenix.Installation!
    
    let fakeUser = Phoenix.User(companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "t")
    let anonymousTokenSuccessfulResponse = "{\"access_token\":\"1JJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let loggedInTokenSuccessfulResponse = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"refresh_token\":\"JJJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let tokenMethod = "POST"
    var tokenUrl: NSURL? {
        return NSURLRequest.phx_URLRequestForLogin(mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL
    }
    
    override func setUp() {
        super.setUp()
        do {
            try mockConfiguration = PhoenixSDK.Phoenix.Configuration(fromFile: "config", inBundle:NSBundle(forClass: PhoenixNetworkRequestTestCase.self))
            mockConfiguration.region = .Europe
            mockOAuthProvider = MockOAuthProvider()
            mockDelegateWrapper = MockPhoenixDelegateWrapper(expectCreationFailed: false, expectLoginFailed: false, expectRoleFailed: false)
            mockNetwork = Network(delegate: mockDelegateWrapper, oauthProvider: mockOAuthProvider)
            mockInstallation = MockPhoenixInstallation.newInstance(mockConfiguration, storage: mockInstallationStorage)
            
            try phoenix = Phoenix(
                withDelegate: mockDelegateWrapper.mockDelegate,
                delegateWrapper: mockDelegateWrapper,
                network: mockNetwork,
                configuration: mockConfiguration,
                oauthProvider: mockOAuthProvider,
                installation: mockInstallation,
                locationManager: PhoenixLocationManager())
            
            // Test individual modules rather than calling startup here.
        }
        catch {
        }
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
        phoenix = nil
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
                print("expectation fulfilled: ", expectation.description)
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