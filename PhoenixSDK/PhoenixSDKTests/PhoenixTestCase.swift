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
            let phoenix = try Phoenix(withFile: "config", inBundle: NSBundle(forClass: PhoenixTestCase.self))
            XCTAssert(phoenix.currentConfiguration.clientID == "CLIENT_ID", "Invalid client ID read")
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing phoenix.")
        }
    }
    
    func testPhoenixConfigurationInitializer(){
        let bundle = NSBundle(forClass: PhoenixTestCase.self)
        
        do {
            let configuration = try Phoenix.Configuration(fromFile: "config", inBundle: bundle)
            let phoenix = try Phoenix(withConfiguration: configuration)
            XCTAssert(phoenix.currentConfiguration.clientID == "CLIENT_ID", "Invalid client ID read")
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing Phoenix")
        }
    }
    
    // Mock configuration fakes an invalid configuration
    func testPhoenixInitializerWithMockConfiguration() {
        do {
            var config = MockConfiguration()
            config.mockInvalid = true
            let _ = try Phoenix(withConfiguration: config)
            XCTAssert(false, "No exception thrown")
        }
        catch PhoenixSDK.ConfigurationError.InvalidPropertyError {
            // correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception thrown")
        }
    }
    
    @objc class Helper:  NSObject, PhoenixNetworkDelegate {
        func authenticationFailed(data: NSData?, response: NSURLResponse?, error: NSError?) {
            
        }
    }
    
    // Mock configuration fakes an invalid configuration
    func testPhoenixGetterSetterWorks() {
        do {
            let phoenix = try Phoenix(withFile: "config", inBundle: NSBundle(forClass: PhoenixTestCase.self))
            XCTAssert(phoenix.currentConfiguration.clientID == "CLIENT_ID", "Invalid client ID read")
            
            
            let helper:PhoenixNetworkDelegate = Helper()
            phoenix.networkDelegate = helper
            
            XCTAssert(phoenix.networkDelegate! === helper, "The getter works")
        }
        catch {
            XCTAssert(false, "There was an error reading the file or initializing phoenix.")
        }
    }
}
