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
        XCTAssert(Phoenix.Region.UnitedStates.urlDomain() == ".com",
            "United States domain is not .com")
    }
    
    func testPSDK21Case2() {
        XCTAssert(Phoenix.Region.Europe.urlDomain() == ".eu",
            "Europe domain is not .eu")
    }
    
    func testPSDK21Case3() {
        XCTAssert(Phoenix.Region.Singapore.urlDomain() == ".com.sg",
            "Singapore domain is not .com.sg")
    }
    
    func testPSDK21Case4() {
        XCTAssert(Phoenix.Region.Australia.urlDomain() == ".com.au",
            "Australia  domain is not .com.au")
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
    
    func testRegionDomain(){
        let correctAssignments:[Phoenix.Region: String] = [
            .UnitedStates   : ".com",
            .Australia      : ".com.au",
            .Europe         : ".eu",
            .Singapore      : ".com.sg"
        ]
        
        for (region, value) in correctAssignments {
            XCTAssert(region.urlDomain() == value, "Incorrect domain value from region \(region)")
        }
    }
    
}
