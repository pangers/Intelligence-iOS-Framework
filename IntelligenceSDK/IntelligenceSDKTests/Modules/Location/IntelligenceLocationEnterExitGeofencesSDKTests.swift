//
//  IntelligenceLocationEnterExitGeofencesSDKTests.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK
import CoreLocation

class IntelligenceLocationEnterExitGeofencesSDKTests: IntelligenceLocationBaseTestCase, LocationModuleDelegate {
    
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
        
        location.locationDelegate = self
        
        // Start monitoring with an expectation.
        startMonitorGeofenceExpectation = expectation(description: "Start monitoring")
        location.startMonitoringGeofences(geofences: geofences)
        waitForExpectations(timeout: 20, handler: nil)

        // After notifying of didStartMonitoring, there's a brief period in which we don't have
        // the correct monitoredRegions in the CLLocationManager. This sleeps helps sort that out.
//        NSThread.sleepForTimeInterval(1)

        // Fire the enter geofence with an expectation.
        enterGeofenceExpectation = expectation(description: "Enter geofence")
        mockLocationManager.fireEnterGeofence(geofence)
        waitForExpectations(timeout: 20, handler: nil)
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
        
        location.locationDelegate = self

        // Start monitoring with an expectation.
        startMonitorGeofenceExpectation = expectation(description: "Start monitoring")
        location.startMonitoringGeofences(geofences: geofences)
        waitForExpectations(timeout: 2, handler: nil)
        
        // After notifying of didStartMonitoring, there's a brief period in which we don't have 
        // the correct monitoredRegions in the CLLocationManager. This sleeps helps sort that out.
//        NSThread.sleepForTimeInterval(1)
        
        // Fire the exit geofence with an expectation.
        exitGeofenceExpectation = expectation(description: "Exit geofence")
        mockLocationManager.fireExitGeofence(geofence)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testGeofencesNotNotifiedWhenNotMonitoring() {
        assertNotCalled = true
        location.locationDelegate = self
        location.stopMonitoringGeofences()
        
        mockLocationManager.fireEnterGeofence(Geofence())
        mockLocationManager.fireExitGeofence(Geofence())
    }

    @objc(intelligenceLocationWithLocation:didEnterGeofence:) func intelligenceLocation(location: LocationModuleProtocol, didEnterGeofence geofence: Geofence) {
        XCTAssertFalse(assertNotCalled)
        
        guard let expectation = enterGeofenceExpectation else {
            return
        }
        
        expectation.fulfill()
        enterGeofenceExpectation = nil
    }
    
    @objc(intelligenceLocationWithLocation:didExitGeofence:) func intelligenceLocation(location: LocationModuleProtocol, didExitGeofence geofence: Geofence) {
        XCTAssertFalse(assertNotCalled)
        
        guard let expectation = exitGeofenceExpectation else {
            return
        }
        
        expectation.fulfill()
        exitGeofenceExpectation = nil
    }
    
    
    @objc(intelligenceLocationWithLocation:didStartMonitoringGeofence:) func intelligenceLocation(location: LocationModuleProtocol, didStartMonitoringGeofence: Geofence) {
        guard let expectation = startMonitorGeofenceExpectation else {
            return
        }
        
        expectation.fulfill()
        startMonitorGeofenceExpectation = nil
    }

}
