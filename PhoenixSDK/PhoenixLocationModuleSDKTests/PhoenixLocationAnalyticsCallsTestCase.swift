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
    
    override func setUp() {
        super.setUp()
        analytics = MockAnalyticsModule()
        (location as! Phoenix.Location).analytics = analytics
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        analytics = nil
        super.tearDown()
    }
    
    func testEnterRegion() {
        (location as! Phoenix.Location).didEnterGeofence(Geofence(), withUserCoordinate: nil)
        analytics.trackedEvents.filter {
            return $0.eventType == "Phoenix.Location.Geofence.Enter"
        }.count == 1
    }
    
    func testExitRegion() {
        (location as! Phoenix.Location).didEnterGeofence(Geofence(), withUserCoordinate: nil)
        analytics.trackedEvents.filter {
            return $0.eventType == "Phoenix.Location.Geofence.Exit"
        }.count == 1
    }
    
}
