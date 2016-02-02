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
    private var credentials = true, disabled = true, locked = true, token = true, creation = true, login = true, role = true
    init(
        expectCredentialsIncorrect: Bool = true,
        expectDisabled: Bool = true,
        expectLocked: Bool = true,
        expectTokenFailed: Bool = true,
        expectCreationFailed: Bool = true,
        expectLoginFailed: Bool = true,
        expectRoleFailed: Bool = true)
    {
        credentials = expectCredentialsIncorrect
        disabled = expectDisabled
        locked = expectLocked
        token = expectTokenFailed
        creation = expectCreationFailed
        login = expectLoginFailed
        role = expectRoleFailed
    }
    
    @objc func credentialsIncorrectForPhoenix(phoenix: Phoenix) {
        XCTAssertTrue(credentials)
    }
    
    @objc func accountDisabledForPhoenix(phoenix: Phoenix) {
        XCTAssertTrue(disabled)
    }
    
    @objc func accountLockedForPhoenix(phoenix: Phoenix) {
        XCTAssertTrue(locked)
    }
    
    @objc func tokenInvalidOrExpiredForPhoenix(phoenix: Phoenix) {
        XCTAssertTrue(token)
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

