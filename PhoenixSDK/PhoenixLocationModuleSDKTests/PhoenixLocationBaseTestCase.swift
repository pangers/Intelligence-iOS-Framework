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
    
    // MARK:- PhoenixInternalDelegate
    func userCreationFailed() {}
    func userLoginRequired() {}
    func userRoleAssignmentFailed() {}
}