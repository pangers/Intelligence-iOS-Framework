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
       // mockDelegate.userCreationFailedForIntelligence(intelligence)
        mockDelegate.userCreationFailed(for: intelligence)
    }
    
    @objc override func userLoginRequired() {
       // mockDelegate.userLoginRequiredForIntelligence(intelligence)
        mockDelegate.userLoginRequired(for: intelligence)
    }
    
    @objc override func userRoleAssignmentFailed() {
       // mockDelegate.userRoleAssignmentFailedForIntelligence(intelligence)
        mockDelegate.userRoleAssignmentFailed(for: intelligence)
    }
}

class MockIntelligenceDelegate: IntelligenceDelegate {
    /// Unable to assign provided sdk_user_role to your newly created user.
    /// This may occur if the Application is configured incorrectly in the backend
    /// and doesn't have the correct permissions or the role doesn't exist.
    @objc public func userRoleAssignmentFailed(for intelligence: Intelligence) {
        XCTAssertTrue(role)
    }
    
    /// User is required to login again, developer must implement this method
    /// you may present a 'Login Screen' or silently call identity.login with
    /// stored credentials.
    @objc  public func userLoginRequired(for intelligence: Intelligence) {
        XCTAssertTrue(login)
    }
    
    /// Unable to create SDK user, this may occur if a user with the randomized
    /// credentials already exists (highly unlikely) or your Application is
    /// configured incorrectly and has the wrong permissions.
    @objc public func userCreationFailed(for intelligence: Intelligence) {
        XCTAssertTrue(creation)
    }
    
    /// This error and description is only returned from the Validate endpoint
    /// if providing an invalid or expired token.
    @objc public func tokenInvalidOrExpired(for intelligence: Intelligence) {
        XCTAssertTrue(token)
    }
    
    /// Account has failed to authentication multiple times and is now locked.
    /// Requires an administrator to unlock the account.
    @objc public func accountLocked(for intelligence: Intelligence) {
        XCTAssertTrue(locked)
    }
    
    /// Account has been disabled and no longer active.
    /// Credentials are no longer valid.
    @objc public func accountDisabled(for intelligence: Intelligence) {
        XCTAssertTrue(disabled)
    }
    
    /// Credentials provided are incorrect.
    /// Will not distinguish between incorrect client or user credentials.
    @objc public func credentialsIncorrect(for intelligence: Intelligence) {
        XCTAssertTrue(credentials)
    }
    
    fileprivate var credentials = true, disabled = true, locked = true, token = true, creation = true, login = true, role = true
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
    
    //    @objc func credentialsIncorrectForIntelligence(_ intelligence: Intelligence) {
    //        XCTAssertTrue(credentials)
    //    }
    
    //    @objc func accountDisabledForIntelligence(_ intelligence: Intelligence) {
    //        XCTAssertTrue(disabled)
    //    }
    
    //    @objc func accountLockedForIntelligence(_ intelligence: Intelligence) {
    //        XCTAssertTrue(locked)
    //    }
    
    //    @objc func tokenInvalidOrExpiredForIntelligence(_ intelligence: Intelligence) {
    //        XCTAssertTrue(token)
    //    }
    
    //    @objc func userCreationFailedForIntelligence(_ intelligence: Intelligence) {
    //        XCTAssertTrue(creation)
    //    }
    
    //    @objc func userLoginRequiredForIntelligence(_ intelligence: Intelligence) {
    //        XCTAssertTrue(login)
    //    }
    
    //    @objc func userRoleAssignmentFailedForIntelligence(_ intelligence: Intelligence) {
    //        XCTAssertTrue(role)
    //    }
}

