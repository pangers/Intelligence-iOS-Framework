//
//  PhoenixBaseTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
@testable import PhoenixSDK

typealias MockCallback = (()->Void)
typealias MockResponse = (data: String?, statusCode: HTTPStatusCode, headers: [String:String]?)

import OHHTTPStubs

class PhoenixBaseTestCase : XCTestCase {
    
    let expectationTimeout:NSTimeInterval = 2
    
    var mockOAuthProvider: MockOAuthProvider!
    var mockDelegateWrapper: MockPhoenixDelegateWrapper!
    var mockNetwork: Network!
    var mockConfiguration: Phoenix.Configuration!
    var phoenix: Phoenix!
    var mockInstallationStorage: InstallationStorage!
    var mockInstallation: Installation!
    
    let fakeUser = Phoenix.User(companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "t")
    
    let anonymousTokenSuccessfulResponse = "{\"access_token\":\"\(applicationAccessToken)=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let loggedInTokenSuccessfulResponse = "{\"access_token\":\"\(userAccessToken)=\",\"refresh_token\":\"\(userRefreshToken)=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let tokenMethod = HTTPRequestMethod.POST
    var tokenUrl: NSURL? {
        return NSURLRequest.phx_URLRequestForLogin(mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL
    }
    
    override func setUp() {
        super.setUp()
        do {
            try mockConfiguration = PhoenixSDK.Phoenix.Configuration(fromFile: "config", inBundle:NSBundle(forClass: PhoenixBaseTestCase.self))
            mockConfiguration.region = .Europe
            mockOAuthProvider = MockOAuthProvider()
            mockDelegateWrapper = MockPhoenixDelegateWrapper(expectCreationFailed: true, expectLoginFailed: true, expectRoleFailed: true)
            mockNetwork = Network(delegate: mockDelegateWrapper, oauthProvider: mockOAuthProvider)
            mockInstallationStorage = InstallationStorage()
            mockInstallation = MockInstallation.newInstance(mockConfiguration, storage: mockInstallationStorage)
            
            try phoenix = Phoenix(
                withDelegate: mockDelegateWrapper.mockDelegate,
                delegateWrapper: mockDelegateWrapper,
                network: mockNetwork,
                configuration: mockConfiguration,
                oauthProvider: mockOAuthProvider,
                installation: mockInstallation,
                locationManager: LocationManager())
            
            
            XCTAssert(phoenix.modules[0] === phoenix.identity)
            XCTAssert(phoenix.modules[1] === phoenix.location)
            XCTAssert(phoenix.modules[2] === phoenix.analytics)
            
            let fakeModule = PhoenixModule(withDelegate: mockDelegateWrapper, network: mockNetwork, configuration: mockConfiguration)
            
            let expectation = expectationWithDescription("Immediate Expectation")
            fakeModule.startup { (success) in
                XCTAssertTrue(success)
                fakeModule.shutdown()
                expectation.fulfill()
            }
            waitForExpectations()
            
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
    
    func mockResponseForURL(url:NSURL!, method:HTTPRequestMethod?, response:MockResponse, expectation: XCTestExpectation? = nil, callback:MockCallback? = nil) {
        mockResponseForURL(url, method: method, responses: [response], callbacks: [callback], expectations: [expectation])
    }
    
    func mockResponseForURL(url:NSURL!, method:HTTPRequestMethod?, responses:[MockResponse], callbacks: [MockCallback?]? = nil, expectations:[XCTestExpectation?]? = nil) {
        
        print("Mock URL: \(url)")
        
        let count = responses.count
        var runs = [(MockCallback?, MockResponse, XCTestExpectation)]()
        for i in 0..<count {
            runs += [ (callbacks?[i], responses[i], expectations?[i] ??
                expectationWithDescription("mock \(url) iteration \(i)")) ]
        }
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                if let method = method?.rawValue where method != request.HTTPMethod {
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
                return OHHTTPStubsResponse(
                    data: stubData,
                    statusCode: Int32(response.statusCode.rawValue),
                    headers:response.headers)
        })
    }
    
    // MARK: - Authentication Mock
    
    func getResponse(status: HTTPStatusCode, body: String) -> MockResponse {
        return MockResponse(data: status == .Success ? body : nil,
            statusCode: status,
            headers: nil)
    }
    
    func mockAuthenticationResponse(response: MockResponse) {
        mockAuthenticationResponses([response])
    }
    
    func mockAuthenticationResponses(responses: [MockResponse]) {
        mockResponseForURL(tokenUrl, method: tokenMethod, responses: responses)
    }
    
    /// Mock the authentication response
    func mockResponseForAuthentication(statusCode:HTTPStatusCode, anonymous: Bool? = true, callback:MockCallback? = nil) {
        let responseData = (statusCode == .Success) ? (anonymous == true ? anonymousTokenSuccessfulResponse : loggedInTokenSuccessfulResponse) : ""
        
        mockResponseForURL(tokenUrl,
            method: tokenMethod,
            response: (data:responseData, statusCode: statusCode, headers: nil),
            callback: callback)
    }
    
    func assertURLNotCalled(url:NSURL, method:HTTPRequestMethod? = .GET) {
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                if let method = method?.rawValue where method != request.HTTPMethod {
                    return false
                }
                
                XCTAssertFalse(request.URL! == url,"URL \(url) was called.")
                return false
            },
            withStubResponse: { _ in
                return OHHTTPStubsResponse() // Never reached
        })
    }
    
    func waitForExpectations() {
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error, "Error in expectation: \(error)")
        }
    }
}