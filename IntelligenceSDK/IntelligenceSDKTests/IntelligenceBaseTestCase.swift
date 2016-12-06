//
//  IntelligenceBaseTestCase.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import IntelligenceSDK

typealias MockCallback = (()->Void)
typealias MockResponse = (data: String?, statusCode: HTTPStatusCode, headers: [String:String]?)

class IntelligenceBaseTestCase : XCTestCase {
    
    let expectationTimeout:TimeInterval = 2
    
    var mockOAuthProvider: MockOAuthProvider!
    var mockDelegateWrapper: MockIntelligenceDelegateWrapper!
    var mockNetwork: Network!
    var mockConfiguration: Intelligence.Configuration!
    var intelligence: Intelligence!
    var mockInstallationStorage: InstallationStorage!
    var mockInstallation: Installation!
    
    let fakeUser = Intelligence.User(companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "t")
    
    let anonymousTokenSuccessfulResponse = "{\"access_token\":\"\(applicationAccessToken)=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let loggedInTokenSuccessfulResponse = "{\"access_token\":\"\(userAccessToken)=\",\"refresh_token\":\"\(userRefreshToken)=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let tokenMethod = HTTPRequestMethod.POST
    var tokenUrl: URL? {
        return URLRequest.int_URLRequestForLogin(mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL
    }
    
    override func setUp() {
        super.setUp()
        do {
            try mockConfiguration = IntelligenceSDK.Intelligence.Configuration(fromFile: "config", inBundle:Bundle(for: IntelligenceBaseTestCase.self))
            mockConfiguration.region = .europe
            mockOAuthProvider = MockOAuthProvider()
            mockDelegateWrapper = MockIntelligenceDelegateWrapper(expectCreationFailed: true, expectLoginFailed: true, expectRoleFailed: true)
            mockNetwork = Network(delegate: mockDelegateWrapper, authenticationChallengeDelegate: NetworkAuthenticationChallengeDelegate(configuration: mockConfiguration), oauthProvider: mockOAuthProvider)
            mockInstallationStorage = InstallationStorage()
            mockInstallation = MockInstallation.newInstance(configuration: mockConfiguration, storage: mockInstallationStorage, oauthProvider: mockOAuthProvider)
            
            try intelligence = Intelligence(
                withDelegate: mockDelegateWrapper.mockDelegate,
                delegateWrapper: mockDelegateWrapper,
                network: mockNetwork,
                configuration: mockConfiguration,
                oauthProvider: mockOAuthProvider,
                installation: mockInstallation,
                locationManager: LocationManager())
            
            
            XCTAssert(intelligence.modules[0] === intelligence.identity)
            XCTAssert(intelligence.modules[1] === intelligence.location)
            XCTAssert(intelligence.modules[2] === intelligence.analytics)
            
            let fakeModule = IntelligenceModule(withDelegate: mockDelegateWrapper, network: mockNetwork, configuration: mockConfiguration)
            
            let expectation = expectation(description: "Immediate Expectation")
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
        intelligence = nil
    }
    
    // MARK: URL Mock
    
    func mockResponseForURL(_ url:URL!, method:HTTPRequestMethod?, response:MockResponse, identifier: String? = nil, expectation: XCTestExpectation? = nil, callback:MockCallback? = nil) {
        mockResponseForURL(url, method: method, responses: [response], identifier: identifier, expectations: [expectation], callbacks: [callback])
    }
    
    func mockResponseForURL(_ url:URL!, method:HTTPRequestMethod?, responses:[MockResponse], identifier: String? = nil, expectations:[XCTestExpectation?]? = nil, callbacks: [MockCallback?]? = nil) {
        
        print("Mock URL: \(url)")
        
        let count = responses.count
        var runs = [(MockCallback?, MockResponse, XCTestExpectation)]()
        for i in 0..<count {
            runs += [ (callbacks?[i], responses[i], expectations?[i] ??
                expectation(description: "mock \(url) iteration \(i)")) ]
        }
        let stub = OHHTTPStubs.stubRequestsPassingTest(
            { request in
                if let method = method?.rawValue , method != request.HTTPMethod {
                    return false
                }
                return request.URL! == url
            },
            withStubResponse: { _ in
                let (callback, response, expectation) = runs.first!
                runs.remove(at: 0)
                // Execute callback before fulfilling expectation so we can chain multiple expectations together
                callback?()
                print("expectation fulfilled: ", expectation.description)
                expectation.fulfill()
                let stubData = ((response.data) ?? "").data(using: String.Encoding.utf8)!
                return OHHTTPStubsResponse(
                    data: stubData,
                    statusCode: Int32(response.statusCode.rawValue),
                    headers:response.headers)
        })
        
        if identifier != nil {
            stub.name = identifier
        }
    }
    
    // MARK: - Authentication Mock
    
    func getResponse(_ status: HTTPStatusCode, body: String) -> MockResponse {
        return MockResponse(data: status == .success ? body : nil,
            statusCode: status,
            headers: nil)
    }
    
    func mockAuthenticationResponse(_ response: MockResponse) {
        mockAuthenticationResponses([response])
    }
    
    func mockAuthenticationResponses(_ responses: [MockResponse]) {
        mockResponseForURL(tokenUrl, method: tokenMethod, responses: responses)
    }
    
    /// Mock the authentication response
    func mockResponseForAuthentication(_ statusCode:HTTPStatusCode, anonymous: Bool? = true, callback:MockCallback? = nil) {
        let responseData = (statusCode == .success) ? (anonymous == true ? anonymousTokenSuccessfulResponse : loggedInTokenSuccessfulResponse) : ""
        
        mockResponseForURL(tokenUrl,
            method: tokenMethod,
            response: (data:responseData, statusCode: statusCode, headers: nil),
            callback: callback)
    }
    
    func assertURLNotCalled(_ url:URL, method:HTTPRequestMethod? = .get) {
        OHHTTPStubs.stubRequestsPassingTest(
            { request in
                if let method = method?.rawValue , method != request.HTTPMethod {
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
