//
//  PhoenixLocationTestCase.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 07/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixLocationTestCase: PhoenixBaseTestCase {
    var location:Phoenix.Location?
    var configuration:Phoenix.Configuration?
    
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
    
    override func setUp() {
        super.setUp()
        do {
            self.configuration = try Phoenix.Configuration(fromFile: "config", inBundle: NSBundle(forClass: PhoenixIdentityTestCase.self))
            let network = Phoenix.Network(withConfiguration: configuration!, withTokenStorage:storage)
            self.location = Phoenix.Location(withNetwork: network, configuration: configuration!)
        }
        catch{
            XCTAssert(false, "Must provide valid config")
        }
    }
    
    override func tearDown() {
        super.tearDown()
        self.configuration = nil
        self.location =  nil
    }
    
    /// Test a valid response is parsed correctly
    func testDownloadGeofencesSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForDownloadGeofences(configuration!).URL!
        
        // Mock 200 on auth
        mockResponseForAuthentication(200)
        
        // Mock
        mockResponseForURL(request,
            method: "GET",
            response: (data: geofencesResponse, statusCode:200, headers:nil))
        
        location!.downloadGeofences { (geofences, error) -> Void in
            XCTAssert(geofences.count == 2, "Geofences failed to load")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    /// Test that network errors are caught and handled properly
    func testDownloadGeofencesFailure() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForDownloadGeofences(configuration!).URL!
        
        // Mock 200 on auth
        mockResponseForAuthentication(200)
        
        // Mock
        mockResponseForURL(request,
            method: "GET",
            response: (data: geofencesResponse, statusCode:401, headers:nil))
        
        location!.downloadGeofences { (geofences, error) -> Void in
            XCTAssert(error != nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
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
    
    /// Test Valid response
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
        } catch let err as GeofenceError {
            switch err {
            case .InvalidPropertyError(_): XCTAssert(true)
            default: XCTAssert(false)
            }
        } catch {
            XCTAssert(false)
        }
    }
    
    /// Test Data is invalid, cannot be loaded as JSON. InvalidJSONError
    func testInvalidJSONGeofences() {
        do {
            NSData().writeToFile(Geofence.jsonPath()!, atomically: true)
            let fences = try Geofence.geofencesFromCache()
            XCTAssert(fences.count == 0)
        } catch let err as GeofenceError {
            switch err {
            case .InvalidJSONError: XCTAssert(true)
            default: XCTAssert(false)
            }
        } catch {
            XCTAssert(false)
        }
    }
    
    /// Test One of these responses will be invalid
    func testOneInvalidGeofence() {
        do {
            try Geofence.storeJSON(geofencesInvalidResponseKey.dataUsingEncoding(NSUTF8StringEncoding)?.phx_jsonDictionary)
            let fences = try Geofence.geofencesFromCache()
            XCTAssert(fences.count == 1)
        } catch {
            XCTAssert(false)
        }
    }
}