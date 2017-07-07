//
//  IntelligenceEnvironmentTestCase.swift
//  IntelligenceSDK
//
//  Created by Michael Lake on 13/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

import XCTest

@testable import IntelligenceSDK

class IntelligenceEnvironmentTestCase: IntelligenceBaseTestCase {
    func testInitWithCode() {
        let correctAssignments = [
            "local" : Intelligence.Environment.local,
            "development" : Intelligence.Environment.development,
            "integration" : Intelligence.Environment.integration,
            "uat" : Intelligence.Environment.uat,
            "staging" : Intelligence.Environment.staging,
            "production" : Intelligence.Environment.production,
        ]
        
        for (code, value) in correctAssignments {
            XCTAssert(Intelligence.Environment(code:code) == value, "Incorrect enum value from string")
        }
        
        XCTAssertNil(Intelligence.Environment(code:"Wrong code"), "Incorrect enum value from string")
    }
}
