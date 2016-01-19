//
//  PhoenixConfigurationTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright (c) 2015 Tigerspike. All rights reserved.
//

import XCTest
@testable import PhoenixSDK

// Refers to test case https://tigerspike.atlassian.net/browse/PSDK-21
// Refers to test case https://tigerspike.atlassian.net/browse/PSDK-22
class PhoenixConfigurationTestCase: PhoenixBaseTestCase {
    
    func testConfigurationFromFileAndBundle() {
        let bundle = NSBundle(forClass: PhoenixConfigurationTestCase.self)
        let cfg = genericConfiguration()
        do {
            let config = Phoenix.Configuration()
            try config.readFromFile("config", inBundle: bundle);
            XCTAssert(config.clientID == cfg.clientID, "The client ID is incorrect")
            XCTAssert(config.clientSecret == cfg.clientSecret, "The client secret is incorrect")
            XCTAssert(config.region == cfg.region, "The region is incorrect")
            XCTAssert(config.enviroment == cfg.enviroment, "The enviroment is incorrect")
            XCTAssert(config.applicationID == cfg.applicationID , "The application Id is incorrect")
            XCTAssert(config.projectID == cfg.projectID, "The project Id is incorrect")
            XCTAssert(config.sdkUserRole == cfg.sdkUserRole, "User role not read correctly")
        }
        catch {
            // nop
            XCTAssert(false, "Couldn't read the file.")
        }
    }
    
    func genericConfiguration() -> Phoenix.Configuration {
        let configuration = Phoenix.Configuration()
        configuration.clientID = "CLIENT_ID" // as in file
        configuration.clientSecret = "CLIENT_SECRET" // as in file
        configuration.region = .Europe
        configuration.enviroment = .Production
        
        configuration.applicationID = 10
        configuration.projectID = 20
        configuration.companyId = 1
        configuration.sdkUserRole = 1008
        
        return configuration
    }
    
    
    func testFileNotFoundInReadFromFile() {
        let config = Phoenix.Configuration()
        
        do {
            try config.readFromFile("Does not exist", inBundle: NSBundle.mainBundle())
            XCTAssert(false, "File not found, but exception not thrown")
        }
        catch let err as ConfigurationError where err == .FileNotFoundError {
        }
        catch {
            XCTAssert(false, "Unexpected exception type.")
        }
    }
    
    func testFileInvalidFileConfiguration() {
        let config = Phoenix.Configuration()
        let bundle = NSBundle(forClass: PhoenixConfigurationTestCase.self)
        
        do {
            try config.readFromFile("wrongjson", inBundle: bundle)
            XCTAssert(false, "File is invalid, but the exception is not thrown")
        }
        catch ConfigurationError.InvalidFileError {
            // correct path
        }
        catch {
           XCTAssert(false, "Unexpected exception type.")
        }
    }
    
    func testFileInvalidPropertyConfiguration() {
        let config = Phoenix.Configuration()
        let bundle = NSBundle(forClass: PhoenixConfigurationTestCase.self)
        
        do {
            try config.readFromFile("invalidproperty", inBundle: bundle)
            XCTAssert(false, "File has invalid properties, but the exception is not thrown")
        }
        catch ConfigurationError.InvalidPropertyError {
            // correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception type.")
        }
    }
    
    func testConfigurationIsValid() {
        let bundle = NSBundle(forClass: PhoenixConfigurationTestCase.self)
        do {
            let config = try Phoenix.Configuration(fromFile: "config", inBundle: bundle);
            XCTAssert(config.isValid, "The configuration provided is invalid")
        }
        catch {
            // nop
            XCTAssert(false, "Couldn't read the file.")
        }
    }
    
    func testConfigurationMissingPropertyError(cfg: Phoenix.Configuration) {
        XCTAssertFalse(cfg.isValid)
        XCTAssertTrue(cfg.hasMissingProperty)
        do {
            let _ = try Phoenix(withDelegate: MockPhoenixDelegate(), configuration: cfg, oauthProvider: mockOAuthProvider)
            XCTAssert(false, "No exception thrown")
        }
        catch ConfigurationError.MissingPropertyError {
            // Correct path
            XCTAssertTrue(true)
        }
        catch {
            XCTAssert(false, "Unexpected exception")
        }
    }
    
    func testConfigurationMissingPropertyErrors() {
        var cfg = genericConfiguration()
        cfg.clientID = ""
        testConfigurationMissingPropertyError(cfg)
        
        cfg = genericConfiguration()
        cfg.clientSecret = ""
        testConfigurationMissingPropertyError(cfg)
        
        cfg = genericConfiguration()
        cfg.companyId = 0
        testConfigurationMissingPropertyError(cfg)
        
        cfg = genericConfiguration()
        cfg.applicationID = 0
        testConfigurationMissingPropertyError(cfg)
        
        cfg = genericConfiguration()
        cfg.projectID = 0
        testConfigurationMissingPropertyError(cfg)
        
        cfg = genericConfiguration()
        cfg.sdkUserRole = 0
        testConfigurationMissingPropertyError(cfg)
        
        cfg = genericConfiguration()
        cfg.region = .NoRegion
        testConfigurationMissingPropertyError(cfg)
        
        cfg = genericConfiguration()
        cfg.enviroment = .NoEnviroment
        testConfigurationMissingPropertyError(cfg)
    }
    
    func testEmptyBaseUrlIfNoRegion(){
        let config = MockConfiguration()
        config.region = .NoRegion
        XCTAssert(config.baseURL(forModule: .NoModule) == nil, "The mock configuration with no region returned an unexpected base url")
    }
    
    func testEmptyBaseUrlIfNoEnviroment(){
        let config = MockConfiguration()
        config.enviroment = .NoEnviroment
        XCTAssert(config.baseURL(forModule: .NoModule) == nil, "The mock configuration with no enviroment returned an unexpected base url")
    }
    
    func testBaseUrl(){
        let config = MockConfiguration()
        XCTAssertEqual(config.baseURL(forModule: .NoModule), NSURL(string: "https://api.uat.phoenixplatform.eu/v2"), "The baseURL is not correct")
    }
}
