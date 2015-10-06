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

typealias MockCallback = (()->Void)
typealias MockResponse = (data:String?,statusCode:Int32,headers:[String:String]?)

class PhoenixLocationBaseTestCase : XCTestCase {
    
    // MARK:- Test data
    
    let tokenUrl = NSURL(string: "https://api.phoenixplatform.eu/identity/v1/oauth/token")!
    let tokenMethod = "POST"
    let anonymousTokenSuccessfulResponse = "{\"access_token\":\"1JJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    let loggedInTokenSuccessfulResponse = "{\"access_token\":\"OTJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"refresh_token\":\"JJJ1a2tyeGZrMzRqM2twdXZ5ZzI4N3QycmFmcWp3ZW0=\",\"token_type\":\"bearer\",\"expires_in\":7200}"
    
    // MARK:- Properties
    
    var storage:MockSimpleStorage!
    var configuration:Phoenix.Configuration!
    var location:PhoenixLocation!
    var network:Network!
    var mockLocationManager:MockCLLocationManager!
    
    // MARK:- Setup and teardown

    override func setUp() {
        super.setUp()
        storage = MockSimpleStorage()
        mockLocationManager = MockCLLocationManager()
        configuration = mockConfiguration()
        network = mockNetwork();
        location = Phoenix.Location(withNetwork: network, configuration: configuration, locationManager: PhoenixLocationManager(locationManager:mockLocationManager))
    }
    
    override func tearDown() {
        super.tearDown()
        location.stopMonitoringGeofences()
        OHHTTPStubs.removeAllStubs()
        configuration = nil
        storage = nil
        location = nil
        network = nil
        mockLocationManager = nil
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
        let successResponse = (anonymous == true ? anonymousTokenSuccessfulResponse : loggedInTokenSuccessfulResponse)
        let responseData = (statusCode == 200) ? successResponse : ""
        
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

    func mockExpiredTokenStorage() {
        storage.accessToken = "Somevalue"
//        storage.tokenExpirationDate = NSDate(timeIntervalSinceNow: -10)
    }
    
    func mockValidTokenStorage() {
        storage.accessToken = "Somevalue"
//        storage.tokenExpirationDate = NSDate(timeIntervalSinceNow: 10)
    }

    func mockOAuth() ->PhoenixOAuth {
        return PhoenixOAuth(tokenType: .Application, tokenStorage:storage)
    }
    
    func mockNetwork() -> Network {
        return Network()
    }
    
    func mockConfiguration() -> Phoenix.Configuration {
        return try! Phoenix.Configuration(fromFile: "config", inBundle: NSBundle(forClass: PhoenixLocationDownloadGeofencesSDKTests.self))
    }

}