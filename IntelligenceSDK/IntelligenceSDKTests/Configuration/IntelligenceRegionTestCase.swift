//
//  IntelligenceRegionTestCase.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK

class IntelligenceRegionTestCase: IntelligenceBaseTestCase {
    func testRegionFromString() {
        let correctAssignments = [
            "US" : Intelligence.Region.unitedStates,
            "EU" : Intelligence.Region.europe,
            "SG" : Intelligence.Region.singapore,
            "AU" : Intelligence.Region.australia
        ]

        for (code, value) in correctAssignments {
            XCTAssert(Intelligence.Region(code: code) == value, "Incorrect enum value from string")
        }

        XCTAssertNil(Intelligence.Region(code: "Wrong code"), "Incorrect enum value from string")

    }
}
