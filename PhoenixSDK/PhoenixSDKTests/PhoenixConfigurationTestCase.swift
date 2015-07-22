//
//  PhoenixConfigurationTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright (c) 2015 Tigerspike. All rights reserved.
//

import XCTest
@testable import PhoenixSDK

class PhoenixConfigurationTestCase: XCTestCase {
    
    func testConfigurationFromFileAndBundle() {
        let clientID="CLIENT_ID" // as in file
        let clientSecret="CLIENT_Secret" // as in file
        let bundle = NSBundle(forClass: PhoenixConfigurationTestCase.self)
        let region:Region = .UnitedStates
        let applicationId = 10
        let projectId = 20
        
        do {
            let config = try PhoenixConfiguration(fromFile: "config", inBundle: bundle);
            
            XCTAssert(config.clientId == clientID, "The client ID is incorrect")
            XCTAssert(config.clientSecret == clientSecret, "The client secret is incorrect")
            XCTAssert(config.region == region, "The region is incorrect")
            XCTAssert(config.applicationID == applicationId , "The application Id is incorrect")
            XCTAssert(config.projectId == projectId, "The project Id is incorrect")
        }
        catch {
            // nop
            XCTAssert(false, "Couldn't read the file.")
        }
    }
    
    func testFileNotFoundInReadFromFile() {
        let config = PhoenixConfiguration();
        
        do {
            try config.readFromFile("Does not exist", inBundle: NSBundle.mainBundle())
            XCTAssert(false, "File not found, but exception not thrown")
        }
        catch PhoenixError.NoSuchConfigFile {
            // nop
        }
        catch let error {
            print(error)
            XCTAssert(false, "Unexpected exception type.")
        }
    }

}
