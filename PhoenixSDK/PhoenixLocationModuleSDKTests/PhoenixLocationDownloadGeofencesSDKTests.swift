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
    
    let geofencesResponse = "{\"TotalRecords\":2,\"Data\":[{\"Geolocation\":{\"Latitude\":51.5143512775593,\"Longitude\":-0.131894946098328},\"Id\":2015,\"ProjectId\":2030,\"Name\":\"test region\",\"DateCreated\":\"2015-10-08T01:07:11.167\",\"DateUpdated\":\"2015-10-08T01:07:11.167\",\"Address\":\"6 Frith St, Soho, London W1D 3JA, UK\",\"Radius\":31.262409258152896,\"IsActive\":true},{\"Geolocation\":{\"Latitude\":51.513687,\"Longitude\":-0.1303285},\"Id\":2012,\"ProjectId\":2030,\"Name\":\"[Phoenix SDK Test Project_1]\",\"DateCreated\":\"2015-10-07T11:31:17.93\",\"DateUpdated\":\"2015-10-07T11:32:27.927\",\"Address\":\"18 Old Compton St, Soho, London W1D 4TN, UK\",\"Radius\":32.78}]}"
    
    let geofencesInvalidResponse = "{\"TotalRecords\":2,\"Data2\":[{\"Geolocation\":{\"Latitude\":51.5143512775593,\"Longitude\":-0.131894946098328},\"Id\":2015,\"ProjectId\":2030,\"Name\":\"test region\",\"DateCreated\":\"2015-10-08T01:07:11.167\",\"DateUpdated\":\"2015-10-08T01:07:11.167\",\"Address\":\"6 Frith St, Soho, London W1D 3JA, UK\",\"Radius\":31.262409258152896,\"IsActive\":true},{\"Geolocation\":{\"Latitude\":51.513687,\"Longitude\":-0.1303285},\"Id\":2012,\"ProjectId\":2030,\"Name\":\"[Phoenix SDK Test Project_1]\",\"DateCreated\":\"2015-10-07T11:31:17.93\",\"DateUpdated\":\"2015-10-07T11:32:27.927\",\"Address\":\"18 Old Compton St, Soho, London W1D 4TN, UK\",\"Radius\":32.78}]}"
    
    let geofencesInvalidResponseKey = "{\"TotalRecords\":2,\"Data\":[{\"Geolocation\":{\"Latitude\":51.5143512775593,\"Longitude\":-0.131894946098328},\"IdFailed\":2015,\"ProjectId\":2030,\"Name\":\"test region\",\"DateCreated\":\"2015-10-08T01:07:11.167\",\"DateUpdated\":\"2015-10-08T01:07:11.167\",\"Address\":\"6 Frith St, Soho, London W1D 3JA, UK\",\"Radius\":31.262409258152896,\"IsActive\":true},{\"Geolocation\":{\"Latitude\":51.513687,\"Longitude\":-0.1303285},\"Id\":2012,\"ProjectId\":2030,\"Name\":\"[Phoenix SDK Test Project_1]\",\"DateCreated\":\"2015-10-07T11:31:17.93\",\"DateUpdated\":\"2015-10-07T11:32:27.927\",\"Address\":\"18 Old Compton St, Soho, London W1D 4TN, UK\",\"Radius\":32.78}]}"
    
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
        let query = GeofenceQuery(location: Coordinate(withLatitude: 2, longitude: 2), radius: 2)
        
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
        let query = GeofenceQuery(location: Coordinate(withLatitude: 2, longitude: 2), radius: 2)
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
