//
//  IntelligenceBaseTestCase.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
@testable import IntelligenceSDK
import OHHTTPStubs

class IntelligenceLocationBaseTestCase : IntelligenceBaseTestCase, IntelligenceInternalDelegate {
    
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
    
    // MARK:- IntelligenceInternalDelegate
    func credentialsIncorrect() {}
    func accountDisabled() {}
    func accountLocked() {}
    func tokenInvalidOrExpired() {}
    func userCreationFailed() {}
    func userLoginRequired() {}
    func userRoleAssignmentFailed() {}
}
