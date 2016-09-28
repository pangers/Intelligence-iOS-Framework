//
//  IntelligenceGeofenceTestcase.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK

class IntelligenceGeofenceTestcase: XCTestCase {
    
    func testEquality() {
        let geofenceA = Geofence()
        geofenceA.id = 1
        let geofenceB = Geofence()
        geofenceB.id = 1
        let geofenceC = Geofence()
        geofenceC.id = 2
        
        let geofenceD:Geofence? = nil
        
        XCTAssert(geofenceA == geofenceB)
        XCTAssert(geofenceA == geofenceA)
        XCTAssert(geofenceA != geofenceC)
        XCTAssert(geofenceB != geofenceC)
        XCTAssert(geofenceB != 1)
        XCTAssert(geofenceB != geofenceD)
    }
}
