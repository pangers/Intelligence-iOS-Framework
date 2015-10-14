//
//  PhoenixRegionTestCase.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixRegionTestCase: PhoenixBaseTestCase {
        
    func testPSDK21Case1() {
        XCTAssert(Phoenix.Region.UnitedStates.baseURL() == "https://api.phoenixplatform.com",
            "United states url does not point to https://api.phoenixplatform.com")
    }
    
    func testPSDK21Case2() {
        XCTAssert(Phoenix.Region.Europe.baseURL() == "https://api.phoenixplatform.eu",
            "Europe url does not point to https://api.phoenixplatform.eu")
    }
    
    func testPSDK21Case3() {
        XCTAssert(Phoenix.Region.Singapore.baseURL() == "https://api.phoenixplatform.com.sg",
            "Singapore url does not point to https://api.phoenixplatform.com.sg")
    }
    
    func testPSDK21Case4() {
        XCTAssert(Phoenix.Region.Australia.baseURL() == "https://api.phoenixplatform.com.au",
            "Australia url does not point to https://api.phoenixplatform.com.au")
    }
    
    func testRegionFromString() {
        let correctAssignments = [
            "US" : Phoenix.Region.UnitedStates,
            "EU" : Phoenix.Region.Europe,
            "SG" : Phoenix.Region.Singapore,
            "AU" : Phoenix.Region.Australia,
        ]
        
        for (code, value) in correctAssignments {
            XCTAssert(Phoenix.Region(code:code) == value, "Incorrect enum value from string")
        }
        
        XCTAssert(Phoenix.Region(code:"Wrong code") == .NoRegion, "Incorrect enum value from string")

    }
    
    func testRegionBaseURL(){
        let correctAssignments:[Phoenix.Region: String] = [
            .UnitedStates   : "https://api.phoenixplatform.com",
            .Australia      : "https://api.phoenixplatform.com.au",
            .Europe         : "https://api.phoenixplatform.eu",
            .Singapore      : "https://api.phoenixplatform.com.sg"
        ]
        
        for (region, value) in correctAssignments {
            XCTAssert(region.baseURL() == value, "Incorrect url value from region \(region)")
        }
    }
    
}
