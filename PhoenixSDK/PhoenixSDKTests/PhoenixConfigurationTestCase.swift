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
        let clientID="CLIENT_ID" // as in file
        let clientSecret="CLIENT_SECRET" // as in file
        let bundle = NSBundle(forClass: PhoenixConfigurationTestCase.self)
        let region: Phoenix.Region = .Europe
        let applicationId = 10
        let projectId = 20
        
        do {
            let config = Phoenix.Configuration()
            try config.readFromFile("config", inBundle: bundle);
            XCTAssert(config.clientID == clientID, "The client ID is incorrect")
            XCTAssert(config.clientSecret == clientSecret, "The client secret is incorrect")
            XCTAssert(config.region == region, "The region is incorrect")
            XCTAssert(config.applicationID == applicationId , "The application Id is incorrect")
            XCTAssert(config.projectID == projectId, "The project Id is incorrect")
        }
        catch {
            // nop
            XCTAssert(false, "Couldn't read the file.")
        }
    }
    
    func testFileNotFoundInReadFromFile() {
        let config = Phoenix.Configuration();
        
        do {
            try config.readFromFile("Does not exist", inBundle: NSBundle.mainBundle())
            XCTAssert(false, "File not found, but exception not thrown")
        }
        catch let err as ConfigurationError where err == .FileNotFoundError {
            print(err)
        }
        catch let error {
            print(error)
            XCTAssert(false, "Unexpected exception type.")
        }
    }
    
    func testFileInvalidFileConfiguration() {
        let config = Phoenix.Configuration();
        let bundle = NSBundle(forClass: PhoenixConfigurationTestCase.self)
        
        do {
            try config.readFromFile("wrongjson", inBundle: bundle)
            XCTAssert(false, "File is invalid, but the exception is not thrown")
        }
        catch ConfigurationError.InvalidFileError {
            // correct path
        }
        catch let error {
            print(error)
            XCTAssert(false, "Unexpected exception type.")
        }
    }
    
    func testFileInvalidPropertyConfiguration() {
        let config = Phoenix.Configuration();
        let bundle = NSBundle(forClass: PhoenixConfigurationTestCase.self)
        
        do {
            try config.readFromFile("invalidproperty", inBundle: bundle)
            XCTAssert(false, "File has invalid properties, but the exception is not thrown")
        }
        catch ConfigurationError.InvalidPropertyError {
            // correct path
        }
        catch let error {
            print(error)
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
    
    func testPSDK21Case5() {
        do {
            let configuration = Phoenix.Configuration()
            configuration.clientSecret = "Secret";
            configuration.projectID = 212;
            configuration.applicationID = 42131;
            configuration.region = .UnitedStates;
            configuration.companyId = 1

            let _ = try Phoenix(withConfiguration: configuration)
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
            configuration.companyId = 1

            let _ = try Phoenix(withConfiguration: configuration)
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
            configuration.companyId = 1

            let _ = try Phoenix(withConfiguration: configuration)
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
            configuration.companyId = 1

            let _ = try Phoenix(withConfiguration: configuration)
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
            configuration.companyId = 1
            
            let _ = try Phoenix(withConfiguration: configuration)
            XCTAssert(false, "No exception thrown")
        }
        catch ConfigurationError.MissingPropertyError {
            // Correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception")
        }
    }

    func testNoCompanyIDInConfiguration() {
        do {
            let configuration = Phoenix.Configuration()
            configuration.clientID = "ID";
            configuration.clientSecret = "SECRET";
            configuration.projectID = 42131;
            configuration.applicationID = 123;
            configuration.region = .Europe;
            
            let _ = try Phoenix(withConfiguration: configuration)
            XCTAssert(false, "No exception thrown")
        }
        catch ConfigurationError.MissingPropertyError {
            // Correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception")
        }
    }

    func testCompanyID0InConfiguration() {
        do {
            let configuration = Phoenix.Configuration()
            configuration.clientID = "ID"
            configuration.clientSecret = "SECRET"
            configuration.projectID = 42131
            configuration.applicationID = 123
            configuration.region = .Europe
            configuration.companyId = 0
            
            let _ = try Phoenix(withConfiguration: configuration)
            XCTAssert(false, "No exception thrown")
        }
        catch ConfigurationError.MissingPropertyError {
            // Correct path
        }
        catch {
            XCTAssert(false, "Unexpected exception")
        }
    }

    func testEmptyBaseUrlIfNoRegion(){
        let config = MockConfiguration()
        config.region = .NoRegion
        XCTAssert(config.baseURL == nil, "The mock configuration with no region returned an unexpected base url")
    }
}
