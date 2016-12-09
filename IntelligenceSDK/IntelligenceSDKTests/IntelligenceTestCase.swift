//
//  IntelligenceTestCase.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
@testable import IntelligenceSDK

class IntelligenceTestCase: IntelligenceBaseTestCase {
    
    func testIntelligenceInitializer() {
        let delegateTester = MockIntelligenceDelegate(expectCreationFailed: false, expectLoginFailed: false, expectRoleFailed: false)
        
        do {
            let intelligence = try Intelligence(withDelegate: delegateTester, file: "config", inBundle: Bundle(for: IntelligenceTestCase.self), oauthProvider: mockOAuthProvider)
            XCTAssert(intelligence.configuration.clientID == "CLIENT_ID", "Invalid client ID read")
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing intelligence.")
        }
    }
    
    func testIntelligenceConfigurationInitializer(){
        let delegateTester = MockIntelligenceDelegate(expectCreationFailed: false, expectLoginFailed: false, expectRoleFailed: false)
        let bundle = Bundle(for: IntelligenceTestCase.self)
        
        do {
            let configuration = try Intelligence.Configuration(fromFile: "config", inBundle: bundle)
            let intelligence = try Intelligence(withDelegate: delegateTester, configuration: configuration, oauthProvider: mockOAuthProvider)
            XCTAssert(intelligence.configuration.clientID == "CLIENT_ID", "Invalid client ID read")
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing Intelligence")
        }
    }
    
    // Mock configuration fakes an invalid configuration
    func testIntelligenceInitializerWithMockConfiguration() {
        let delegateTester = MockIntelligenceDelegate(expectCreationFailed: false, expectLoginFailed: false, expectRoleFailed: false)
        
        do {
            let config = MockConfiguration()
            config.mockInvalid = true
            let _ = try Intelligence(withDelegate:delegateTester, configuration: config, oauthProvider: mockOAuthProvider)
            XCTAssert(false, "No exception thrown")
        }
        catch IntelligenceSDK.ConfigurationError.missingPropertyError {
            // correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception thrown")
        }
    }
    
    // Mock configuration fakes an invalid configuration
    func testIntelligenceGetterSetterWorks() {
        let delegateTester = MockIntelligenceDelegate(expectCreationFailed: false, expectLoginFailed: false, expectRoleFailed: false)
        
        do {
            _ = try Intelligence(withDelegate: delegateTester, file: "config", inBundle: Bundle(for: IntelligenceTestCase.self), oauthProvider: mockOAuthProvider)
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing intelligence.")
        }
    }
}
