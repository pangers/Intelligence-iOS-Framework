//
//  MockDelegate.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class MockPhoenixDelegateWrapper: PhoenixDelegateWrapper {
    let mockDelegate: PhoenixDelegate
    init(
        expectCreationFailed: Bool = false,
        expectLoginFailed: Bool = false,
        expectRoleFailed: Bool = false)
    {
        mockDelegate = MockPhoenixDelegate(
            expectCreationFailed: expectCreationFailed,
            expectLoginFailed:expectLoginFailed,
            expectRoleFailed:expectRoleFailed)
    }
    
    @objc override func userCreationFailed() {
        mockDelegate.userCreationFailedForPhoenix(phoenix)
    }
    
    @objc override func userLoginRequired() {
        mockDelegate.userLoginRequiredForPhoenix(phoenix)
    }
    
    @objc override func userRoleAssignmentFailed() {
        mockDelegate.userRoleAssignmentFailedForPhoenix(phoenix)
    }
}

class MockPhoenixDelegate: PhoenixDelegate {
    private var creation = false, login = false, role = false
    init(
        expectCreationFailed: Bool = false,
        expectLoginFailed: Bool = false,
        expectRoleFailed: Bool = false)
    {
        creation = expectCreationFailed
        login = expectLoginFailed
        role = expectRoleFailed
    }
    
    @objc func userCreationFailedForPhoenix(phoenix: Phoenix) {
        XCTAssertTrue(creation)
    }
    
    @objc func userLoginRequiredForPhoenix(phoenix: Phoenix) {
        XCTAssertTrue(login)
    }
    
    @objc func userRoleAssignmentFailedForPhoenix(phoenix: Phoenix) {
        XCTAssertTrue(role)
    }
}

