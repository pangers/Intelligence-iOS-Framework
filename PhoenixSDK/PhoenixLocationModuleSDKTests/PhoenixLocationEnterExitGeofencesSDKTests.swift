//
//  PhoenixLocationEnterExitGeofencesSDKTests.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK
import CoreLocation

class PhoenixLocationEnterExitGeofencesSDKTests: PhoenixLocationBaseTestCase, PhoenixLocationDelegate {
    
    var enterGeofenceExpectation:XCTestExpectation?
    var exitGeofenceExpectation:XCTestExpectation?
    var startMonitorGeofenceExpectation:XCTestExpectation?
    var assertNotCalled = false
    
    override func tearDown() {
        assertNotCalled = false
        enterGeofenceExpectation = nil
        exitGeofenceExpectation = nil
        super.tearDown()
    }
    
    func testEnterGeofenceNotify() {
        let geofence = Geofence()
        
        // Tigerspike from gpx file
        geofence.latitude = 51.5201906
        geofence.longitude = -0.1341973
        geofence.radius = 100
        geofence.id = 1
        geofence.name = "Tigerspike"
        
        let geofences = [ geofence ]
        
        location.delegate = self
        
        // Start monitoring with an expectation.
        startMonitorGeofenceExpectation = expectationWithDescription("Start monitoring")
        location.startMonitoringGeofences(geofences)
        waitForExpectationsWithTimeout(2, handler: nil)

        // After notifying of didStartMonitoring, there's a brief period in which we don't have
        // the correct monitoredRegions in the CLLocationManager. This sleeps helps sort that out.
//        NSThread.sleepForTimeInterval(1)

        // Fire the enter geofence with an expectation.
        enterGeofenceExpectation = expectationWithDescription("Enter geofence")
        mockLocationManager.fireEnterGeofence(geofence)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testExitGeofenceNotify() {
        // Tigerspike from gpx file
        let geofence = Geofence()
        geofence.latitude = 51.5201906
        geofence.longitude = -0.1341973
        geofence.radius = 100
        geofence.id = 1
        geofence.name = "Tigerspike"
        
        let geofences = [ geofence ]
        
        location.delegate = self

        // Start monitoring with an expectation.
        startMonitorGeofenceExpectation = expectationWithDescription("Start monitoring")
        location.startMonitoringGeofences(geofences)
        waitForExpectationsWithTimeout(2, handler: nil)
        
        // After notifying of didStartMonitoring, there's a brief period in which we don't have 
        // the correct monitoredRegions in the CLLocationManager. This sleeps helps sort that out.
//        NSThread.sleepForTimeInterval(1)
        
        // Fire the exit geofence with an expectation.
        exitGeofenceExpectation = expectationWithDescription("Exit geofence")
        mockLocationManager.fireExitGeofence(geofence)
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testGeofencesNotNotifiedWhenNotMonitoring() {
        assertNotCalled = true
        location.delegate = self
        location.stopMonitoringGeofences()
        
        mockLocationManager.fireEnterGeofence(Geofence())
        mockLocationManager.fireExitGeofence(Geofence())
    }

    func phoenixLocation(location:PhoenixLocation, didEnterGeofence geofence:Geofence) {
        XCTAssertFalse(assertNotCalled)
        
        guard let expectation = enterGeofenceExpectation else {
            return
        }
        
        expectation.fulfill()
        enterGeofenceExpectation = nil
    }
    
    func phoenixLocation(location:PhoenixLocation, didExitGeofence geofence:Geofence) {
        XCTAssertFalse(assertNotCalled)
        
        guard let expectation = exitGeofenceExpectation else {
            return
        }
        
        expectation.fulfill()
        exitGeofenceExpectation = nil
    }
    
    
    func phoenixLocation(location: PhoenixLocation, didStartMonitoringGeofence: Geofence) {
        guard let expectation = startMonitorGeofenceExpectation else {
            return
        }
        
        expectation.fulfill()
        startMonitorGeofenceExpectation = nil
    }

}
