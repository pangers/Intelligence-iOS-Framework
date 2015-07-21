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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConfigurationFromFileAndBundle() {
        let clientID="CLIENT_ID" // as in file
        let clientSecret="CLIENT_Secret" // as in file
        let bundle = NSBundle(forClass: PhoenixConfigurationTestCase.self)
        do {
            let config = try PhoenixConfiguration(fromFile: "config", inBundle: bundle);
            
            XCTAssert(config.clientId == clientID, "The client ID is incorrect")
            XCTAssert(config.clientSecret == clientSecret, "The client secret is incorrect")
        }
        catch {
            // nop
        }
    }
    
    func testFileNotFoundInReadFromFile() {
        let config = PhoenixConfiguration();
        
        do {
            try config.readFromFile("Does not exist", inBundle: NSBundle.mainBundle())
            XCTAssert(false, "File not found, but exception not thrown")
        }
        catch PhoenixGenericErrors.NoSuchConfigFile {
            // nop
        }
        catch let error {
            print(error)
            XCTAssert(false, "Unexpected exception type.")
        }
    }
    
//    func testConfigurationProgrammatically() {
//        let clientID="CLIENT_ID"
//        let clientSecret="CLIENT_Secret"
//        let config = PhoenixConfiguration(clientId:clientID, clientSecret:clientSecret)
//        
//        XCTAssert(config.clientId == clientID, "The client ID is incorrect")
//        XCTAssert(config.clientSecret == clientSecret, "The client secret is incorrect")
//    }
//
}
