//
//  PhoenixTestCase.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
@testable import PhoenixSDK

class PhoenixTestCase: PhoenixBaseTestCase {
    
    func testPhoenixInitializer() {
        let delegateTester = PhoenixDelegateTest(expectCreationFailed: false, expectLoginFailed: false, expectRoleFailed: false)
        
        do {
            let phoenix = try Phoenix(withDelegate: delegateTester, oauthStorage:storage, file: "config", inBundle: NSBundle(forClass: PhoenixTestCase.self))
            XCTAssert(phoenix.configuration.clientID == "CLIENT_ID", "Invalid client ID read")
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing phoenix.")
        }
    }
    
    func testPhoenixConfigurationInitializer(){
        let delegateTester = PhoenixDelegateTest(expectCreationFailed: false, expectLoginFailed: false, expectRoleFailed: false)
        let bundle = NSBundle(forClass: PhoenixTestCase.self)
        
        do {
            let configuration = try Phoenix.Configuration(fromFile: "config", inBundle: bundle)
            let phoenix = try Phoenix(withDelegate: delegateTester, configuration: configuration, oauthStorage:storage)
            XCTAssert(phoenix.configuration.clientID == "CLIENT_ID", "Invalid client ID read")
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing Phoenix")
        }
    }
    
    // Mock configuration fakes an invalid configuration
    func testPhoenixInitializerWithMockConfiguration() {
        let delegateTester = PhoenixDelegateTest(expectCreationFailed: false, expectLoginFailed: false, expectRoleFailed: false)
        
        do {
            let config = MockConfiguration()
            config.mockInvalid = true
            let _ = try Phoenix(withDelegate:delegateTester, configuration: config, oauthStorage:storage)
            XCTAssert(false, "No exception thrown")
        }
        catch PhoenixSDK.ConfigurationError.InvalidPropertyError {
            // correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception thrown")
        }
    }
    
    // Mock configuration fakes an invalid configuration
    func testPhoenixGetterSetterWorks() {
        let delegateTester = PhoenixDelegateTest(expectCreationFailed: false, expectLoginFailed: false, expectRoleFailed: false)
        
        do {
            _ = try Phoenix(withDelegate: delegateTester, oauthStorage:storage, file: "config", inBundle: NSBundle(forClass: PhoenixTestCase.self))
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing phoenix.")
        }
    }
}
