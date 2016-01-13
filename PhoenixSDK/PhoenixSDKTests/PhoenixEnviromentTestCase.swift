//
//  PhoenixEnviromentTestCase.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 13/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

import XCTest

@testable import PhoenixSDK

class PhoenixEnviromentTestCase: PhoenixBaseTestCase {
    func testInitWithCode() {
        let correctAssignments = [
            "uat" : Phoenix.Enviroment.UAT,
            "production" : Phoenix.Enviroment.Production,
        ]
        
        for (code, value) in correctAssignments {
            XCTAssert(Phoenix.Enviroment(code:code) == value, "Incorrect enum value from string")
        }
        
        XCTAssert(Phoenix.Enviroment(code:"Wrong code") == .NoEnviroment, "Incorrect enum value from string")
    }
    
    func testURLDomain(){
        let correctAssignments:[Phoenix.Enviroment: String] = [
            .UAT        : "uat",
            .Production : "",
        ]
        
        for (enviroment, value) in correctAssignments {
            XCTAssert(enviroment.urlEnviroment() == value, "Incorrect value from enviroment \(enviroment)")
        }
        
        XCTAssert(Phoenix.Enviroment.NoEnviroment.urlEnviroment() == nil, "Incorrect value from .NoEnviroment")
    }
}
