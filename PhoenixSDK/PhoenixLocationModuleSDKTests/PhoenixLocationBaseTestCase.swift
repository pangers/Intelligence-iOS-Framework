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

class PhoenixLocationBaseTestCase : PhoenixBaseTestCase, PhoenixInternalDelegate {
    
    // MARK:- Properties
    
    var location:LocationModuleProtocol!
    var mockLocationManager:MockCLLocationManager!
    
    // MARK:- Setup and teardown

    override func setUp() {
        super.setUp()
        mockLocationManager = MockCLLocationManager()
        
        location = LocationModule(withDelegate: self, network: mockNetwork, configuration: mockConfiguration, locationManager: LocationManager(locationManager:mockLocationManager))
    }
    
    override func tearDown() {
        super.tearDown()
        location.stopMonitoringGeofences()
        OHHTTPStubs.removeAllStubs()
        location = nil
        mockLocationManager = nil
    }
    
    // MARK: URL Mock
    
    func mockResponseForURL(url:NSURL!, method:String?, response:(data:String?,statusCode:HTTPStatusCode,headers:[String:String]?), expectation: XCTestExpectation? = nil, callback:MockCallback? = nil) {
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
                return OHHTTPStubsResponse(
                    data: stubData,
                    statusCode: Int32(response.statusCode.rawValue),
                    headers:response.headers)
        })
    }
    
    // MARK: - Authentication Mock

    func mockOAuth() -> MockOAuthProvider {
        let oauth = MockOAuthProvider()
        oauth.fakeAccessToken(oauth.sdkUserOAuth)
        return oauth
    }
    
    // MARK:- PhoenixInternalDelegate
    func userCreationFailed() {}
    func userLoginRequired() {}
    func userRoleAssignmentFailed() {}
}