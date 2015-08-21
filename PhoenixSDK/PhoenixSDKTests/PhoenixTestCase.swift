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
        do {
            let phoenix = try Phoenix(withFile: "config", inBundle: NSBundle(forClass: PhoenixTestCase.self), withTokenStorage:storage, disableLocation: true)
            XCTAssert(phoenix.configuration.clientID == "CLIENT_ID", "Invalid client ID read")
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing phoenix.")
        }
    }
    
    func testPhoenixConfigurationInitializer(){
        let bundle = NSBundle(forClass: PhoenixTestCase.self)
        
        do {
            let configuration = try Phoenix.Configuration(fromFile: "config", inBundle: bundle)
            let phoenix = try Phoenix(withConfiguration: configuration, tokenStorage:storage, disableLocation: true)
            XCTAssert(phoenix.configuration.clientID == "CLIENT_ID", "Invalid client ID read")
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing Phoenix")
        }
    }
    
    // Mock configuration fakes an invalid configuration
    func testPhoenixInitializerWithMockConfiguration() {
        do {
            let config = MockConfiguration()
            config.mockInvalid = true
            let _ = try Phoenix(withConfiguration: config, tokenStorage:storage, disableLocation: true)
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
        do {
            _ = try Phoenix(withFile: "config", inBundle: NSBundle(forClass: PhoenixTestCase.self), withTokenStorage:storage, disableLocation: true)
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing phoenix.")
        }
    }
}
