//
//  PhoenixLocationModuleSDKTests.swift
//  PhoenixLocationModuleSDKTests
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixLocationDownloadGeofencesSDKTests: PhoenixLocationBaseTestCase {
    
    // MARK:- Test data
    
    let geofencesResponse = "{" +
        "\"TotalRecords\": 2," +
        "\"Data\": [{" +
        "\"Geolocation\": {" +
        "\"Latitude\": 51.5229702," +
        "\"Longitude\": -0.1400708}," +
        "\"Id\": 1005," +
        "\"ProjectId\": 2030," +
        "\"Name\": \"Fitzroy Square\"," +
        "\"CreateDate\": \"2015-07-08T08:05:23.55\"," +
        "\"ModifyDate\": \"2015-07-08T08:05:23.55\"," +
        "\"Address\": \"6 Fitzroy Square, Kings Cross, London W1T 5HJ, UK\"," +
        "\"Radius\": 61.62},{" +
        "\"Geolocation\": {" +
        "\"Latitude\": 51.5201001," +
        "\"Longitude\": -0.1342616}," +
        "\"Id\": 1004," +
        "\"ProjectId\": 2030," +
        "\"Name\": \"Tigerspike London\"," +
        "\"CreateDate\": \"2015-07-08T08:04:48.403\"," +
        "\"ModifyDate\": \"2015-07-08T08:04:48.403\"," +
        "\"Address\": \"10-16 Goodge Street, Fitzrovia, London W1T 2QB, UK\"," +
        "\"Radius\": 26.18}]" +
    "}"
    
    let geofencesInvalidResponse = "{" +
        "\"TotalRecords\": 2," +
        "\"Data2\": [{" +
        "\"Geolocation\": {" +
        "\"Latitude\": 51.5229702," +
        "\"Longitude\": -0.1400708}," +
        "\"Id\": 1005," +
        "\"ProjectId\": 2030," +
        "\"Name\": \"Fitzroy Square\"," +
        "\"CreateDate\": \"2015-07-08T08:05:23.55\"," +
        "\"ModifyDate\": \"2015-07-08T08:05:23.55\"," +
        "\"Address\": \"6 Fitzroy Square, Kings Cross, London W1T 5HJ, UK\"," +
        "\"Radius\": 61.62},{" +
        "\"Geolocation\": {" +
        "\"Latitude\": 51.5201001," +
        "\"Longitude\": -0.1342616}," +
        "\"Id\": 1004," +
        "\"ProjectId\": 2030," +
        "\"Name\": \"Tigerspike London\"," +
        "\"CreateDate\": \"2015-07-08T08:04:48.403\"," +
        "\"ModifyDate\": \"2015-07-08T08:04:48.403\"," +
        "\"Address\": \"10-16 Goodge Street, Fitzrovia, London W1T 2QB, UK\"," +
        "\"Radius\": 26.18}]" +
    "}"
    
    let geofencesInvalidResponseKey = "{" +
        "\"TotalRecords\": 2," +
        "\"Data\": [{" +
        "\"Geolocation\": {" +
        "\"Latitude\": 51.5229702," +
        "\"Longitude\": -0.1400708}," +
        "\"IdFailed\": 1005," +
        "\"ProjectId\": 2030," +
        "\"Name\": \"Fitzroy Square\"," +
        "\"CreateDate\": \"2015-07-08T08:05:23.55\"," +
        "\"ModifyDate\": \"2015-07-08T08:05:23.55\"," +
        "\"Address\": \"6 Fitzroy Square, Kings Cross, London W1T 5HJ, UK\"," +
        "\"Radius\": 61.62},{" +
        "\"Geolocation\": {" +
        "\"Latitude\": 51.5201001," +
        "\"Longitude\": -0.1342616}," +
        "\"Id\": 1004," +
        "\"ProjectId\": 2030," +
        "\"Name\": \"Tigerspike London\"," +
        "\"CreateDate\": \"2015-07-08T08:04:48.403\"," +
        "\"ModifyDate\": \"2015-07-08T08:04:48.403\"," +
        "\"Address\": \"10-16 Goodge Street, Fitzrovia, London W1T 2QB, UK\"," +
        "\"Radius\": 26.18}]" +
    "}"
    
    let errorResponse = "{" +
        "\"error\": \"invalid_request\"," +
        "\"error_description\": \"Invalid ordering property 'Something'.\"" +
    "}"
        
    // MARK:- Helpers
    
    func mockDownloadGeofences(status: HTTPStatusCode = .Success, query: GeofenceQuery, body: String? = nil) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForDownloadGeofences(mockOAuthProvider.sdkUserOAuth, configuration: mockConfiguration, network: mockNetwork, query: query).URL!,
            method: .GET,
            response: getResponse(status, body: body ?? geofencesResponse))
    }
    
    
    /// Test a valid response is parsed correctly
    func testDownloadGeofencesSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let query = GeofenceQuery(location: Coordinate(withLatitude: 2, longitude: 2))
        query.setDefaultValues()
        
        mockDownloadGeofences(.Success, query: query)
        
        // Mock a valid token
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.sdkUserOAuth, fakeUser: fakeUser)
        
        location!.downloadGeofences(query) { (geofences, error) -> Void in
            XCTAssert(geofences?.count == 2, "Geofences failed to load")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    /// Test that network errors are caught and handled properly
    func testDownloadGeofencesFailure() {
        let query = GeofenceQuery(location: Coordinate(withLatitude: 2, longitude: 2))
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        mockDownloadGeofences(.Success, query: query, body: errorResponse)
        
        // Mock a valid token
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.sdkUserOAuth, fakeUser: fakeUser)
        
        location!.downloadGeofences(query) { (geofences, error) -> Void in
            XCTAssert(error != nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    /// Test loading the geofences with a missing json fails
    func testLoadGeofencesMissingJSON() {
        do {
            try Geofence.geofences(withJSON: nil)
            XCTAssert(false, "Cannot load with nil")
        }
        catch let err as RequestError {
            XCTAssert(err == RequestError.ParseError, "Expected parse error")
        }
        catch {
            XCTAssert(false, "Unexpected")
        }
    }
    
    /// Test valid read
    func testStoreGeofences() {
        do {
            try Geofence.storeJSON(geofencesResponse.dataUsingEncoding(NSUTF8StringEncoding)?.phx_jsonDictionary)
        } catch {
            XCTAssert(false)
        }
    }
    
    /// Test Store holds more than one geofence.
    func testStoreReadGeofences() {
        do {
            try Geofence.storeJSON(geofencesResponse.dataUsingEncoding(NSUTF8StringEncoding)?.phx_jsonDictionary)
            let fences = try Geofence.geofencesFromCache()
            XCTAssert(fences.count == 2)
        } catch {
            XCTAssert(false)
        }
    }
    
    /// Test Missing data key from response. InvalidPropertyError
    func testStoreReadMissingDataKeyGeofences() {
        do {
            try Geofence.storeJSON(geofencesInvalidResponse.dataUsingEncoding(NSUTF8StringEncoding)?.phx_jsonDictionary)
            let fences = try Geofence.geofencesFromCache()
            XCTAssert(fences.count == 0)
        }
        catch let err as GeofenceError {
            switch err {
            case .InvalidPropertyError(_):
                XCTAssert(true)
            default:
                XCTAssert(false)
            }
        }
        catch {
            XCTAssert(false)
        }
    }
    
    /// Test Data is invalid, cannot be loaded as JSON. InvalidJSONError
    func testInvalidJSONGeofences() {
        do {
            NSData().writeToFile(Geofence.jsonPath()!, atomically: true)
            let fences = try Geofence.geofencesFromCache()
            XCTAssert(fences.count == 0)
        }
        catch let err as RequestError {
            switch err {
            case .ParseError:
                XCTAssert(true)
            default:
                XCTAssert(false)
            }
        }
        catch {
            XCTAssert(false)
        }
    }
    
    /// Test One of these responses will be invalid
    func testGeofenceStore() {
        do {
            try Geofence.storeJSON(geofencesInvalidResponseKey.dataUsingEncoding(NSUTF8StringEncoding)?.phx_jsonDictionary)
            let fences = try Geofence.geofencesFromCache()
            XCTAssert(fences.count == 1)
        } catch {
            XCTAssert(false)
        }
    }
    
}
