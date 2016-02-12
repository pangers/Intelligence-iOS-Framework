//
//  MockDelegate.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK

class MockIntelligenceDelegateWrapper: IntelligenceDelegateWrapper {
    let mockDelegate: IntelligenceDelegate
    init(
        expectCreationFailed: Bool = false,
        expectLoginFailed: Bool = false,
        expectRoleFailed: Bool = false)
    {
        mockDelegate = MockIntelligenceDelegate(
            expectCreationFailed: expectCreationFailed,
            expectLoginFailed:expectLoginFailed,
            expectRoleFailed:expectRoleFailed)
    }
    
    @objc override func userCreationFailed() {
        mockDelegate.userCreationFailedForIntelligence(intelligence)
    }
    
    @objc override func userLoginRequired() {
        mockDelegate.userLoginRequiredForIntelligence(intelligence)
    }
    
    @objc override func userRoleAssignmentFailed() {
        mockDelegate.userRoleAssignmentFailedForIntelligence(intelligence)
    }
}

class MockIntelligenceDelegate: IntelligenceDelegate {
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
    
    @objc func credentialsIncorrectForIntelligence(intelligence: Intelligence) {
        XCTAssertTrue(credentials)
    }
    
    @objc func accountDisabledForIntelligence(intelligence: Intelligence) {
        XCTAssertTrue(disabled)
    }
    
    @objc func accountLockedForIntelligence(intelligence: Intelligence) {
        XCTAssertTrue(locked)
    }
    
    @objc func tokenInvalidOrExpiredForIntelligence(intelligence: Intelligence) {
        XCTAssertTrue(token)
    }
    
    @objc func userCreationFailedForIntelligence(intelligence: Intelligence) {
        XCTAssertTrue(creation)
    }
    
    @objc func userLoginRequiredForIntelligence(intelligence: Intelligence) {
        XCTAssertTrue(login)
    }
    
    @objc func userRoleAssignmentFailedForIntelligence(intelligence: Intelligence) {
        XCTAssertTrue(role)
    }
}

