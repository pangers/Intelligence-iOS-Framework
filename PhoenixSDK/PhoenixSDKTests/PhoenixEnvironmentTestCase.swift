//
//  PhoenixEnvironmentTestCase.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 13/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

import XCTest

@testable import PhoenixSDK

class PhoenixEnvironmentTestCase: PhoenixBaseTestCase {
    func testInitWithCode() {
        let correctAssignments = [
            "uat" : Phoenix.Environment.UAT,
            "production" : Phoenix.Environment.Production,
        ]
        
        for (code, value) in correctAssignments {
            XCTAssert(Phoenix.Environment(code:code) == value, "Incorrect enum value from string")
        }
        
        XCTAssertNil(Phoenix.Environment(code:"Wrong code"), "Incorrect enum value from string")
    }
}
