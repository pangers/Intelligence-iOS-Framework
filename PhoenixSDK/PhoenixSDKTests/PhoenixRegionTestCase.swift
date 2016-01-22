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
}
