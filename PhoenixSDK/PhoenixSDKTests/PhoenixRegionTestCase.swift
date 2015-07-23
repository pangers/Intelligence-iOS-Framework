//
//  PhoenixRegionTestCase.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixRegionTestCase: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegionFromString() {
        let correctAssignments = [
            "US" : Phoenix.Region.UnitedStates,
            "EU" : Phoenix.Region.Europe,
            "SG" : Phoenix.Region.Singapore,
            "AU" : Phoenix.Region.Australia,
        ]
        
        for (code, value) in correctAssignments {
            XCTAssert(Phoenix.Region.fromString(code) == value, "Incorrect enum value from string")
        }
        
        XCTAssert(Phoenix.Region.fromString("Wrong code") == nil, "Incorrect enum value from string")

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
