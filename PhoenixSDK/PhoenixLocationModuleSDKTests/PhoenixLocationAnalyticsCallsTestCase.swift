//
//  PhoenixLocationAnalyticsCallsTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixLocationAnalyticsCallsTestCase: PhoenixLocationBaseTestCase {
    
    var analytics:MockAnalyticsModule!
    var geofence:Geofence!
    
    override func setUp() {
        super.setUp()
        analytics = MockAnalyticsModule()
        geofence = Geofence()
        geofence.id = 100
        
        (location as! PhoenixLocation).analytics = analytics
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        analytics = nil
        super.tearDown()
    }
    
    func testEnterRegion() {
        (location as! PhoenixLocation).didEnterGeofence(geofence, withUserCoordinate: nil)
        analytics.trackedEvents.filter {
            return $0.eventType == "Phoenix.Location.Geofence.Enter" && $0.targetId == String(geofence.id)
        }.count == 1
    }
    
    func testExitRegion() {
        (location as! PhoenixLocation).didEnterGeofence(geofence, withUserCoordinate: nil)
        analytics.trackedEvents.filter {
            return $0.eventType == "Phoenix.Location.Geofence.Exit" && $0.targetId == String(geofence.id)
        }.count == 1
    }
    
}
