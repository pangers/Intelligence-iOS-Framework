//
//  PSDK21TestCases.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 23/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

// Refers to test case https://tigerspike.atlassian.net/browse/PSDK-21
class PSDK21TestCases: XCTestCase {
    
    func testPSDK21Case1() {
        XCTAssert(Phoenix.Region.UnitedStates.baseURL() == "https://api.phoenixplatform.com",
            "United states url does not point to https://api.phoenixplatform.com")
    }

    func testPSDK21Case2() {
        XCTAssert(Phoenix.Region.Europe.baseURL() == "https://api.phoenixplatform.eu",
            "Europe url does not point to https://api.phoenixplatform.eu")
    }

    func testPSDK21Case3() {
        XCTAssert(Phoenix.Region.Singapore.baseURL() == "https://api.phoenixplatform.com.sg",
            "Singapore url does not point to https://api.phoenixplatform.com.sg")
    }

    func testPSDK21Case4() {
        XCTAssert(Phoenix.Region.Australia.baseURL() == "https://api.phoenixplatform.com.au",
            "Australia url does not point to https://api.phoenixplatform.com.au")
    }
    
    func testPSDK21Case5() {
        do {
            let configuration = Phoenix.Configuration()
            configuration.clientSecret = "Secret";
            configuration.projectID = 212;
            configuration.applicationID = 42131;
            configuration.region = .UnitedStates;
            
            let _ = Phoenix(withConfiguration: configuration)
            XCTAssert(false, "No exception thrown")
        }
        catch ConfigurationError.MissingPropertyError {
            // Correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception")
        }
    }
    
    func testPSDK21Case6() {
        do {
            let configuration = Phoenix.Configuration()
            configuration.clientID = "ID";
            configuration.projectID = 212;
            configuration.applicationID = 42131;
            configuration.region = .UnitedStates;
            
            let _ = Phoenix(withConfiguration: configuration)
            XCTAssert(false, "No exception thrown")
        }
        catch ConfigurationError.MissingPropertyError {
            // Correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception")
        }
    }
    
    func testPSDK21Case7() {
        do {
            let configuration = Phoenix.Configuration()
            configuration.clientID = "ID";
            configuration.clientSecret = "SECRET";
            configuration.applicationID = 42131;
            configuration.region = .UnitedStates;
            
            let _ = Phoenix(withConfiguration: configuration)
            XCTAssert(false, "No exception thrown")
        }
        catch ConfigurationError.MissingPropertyError {
            // Correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception")
        }
    }
    
    func testPSDK21Case8() {
        do {
            let configuration = Phoenix.Configuration()
            configuration.clientID = "ID";
            configuration.clientSecret = "SECRET";
            configuration.projectID = 42131;
            configuration.region = .UnitedStates;
            
            let _ = Phoenix(withConfiguration: configuration)
            XCTAssert(false, "No exception thrown")
        }
        catch ConfigurationError.MissingPropertyError {
            // Correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception")
        }
    }
    
    func testPSDK21Case9() {
        do {
            let configuration = Phoenix.Configuration()
            configuration.clientID = "ID";
            configuration.clientSecret = "SECRET";
            configuration.projectID = 42131;
            configuration.applicationID = 123;
            
            let _ = Phoenix(withConfiguration: configuration)
            XCTAssert(false, "No exception thrown")
        }
        catch ConfigurationError.MissingPropertyError {
            // Correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception")
        }
    }
    
}
