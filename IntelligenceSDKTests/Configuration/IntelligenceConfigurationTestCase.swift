//
//  IntelligenceConfigurationTestCase.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright (c) 2015 Tigerspike. All rights reserved.
//

import XCTest
@testable import IntelligenceSDK

// Refers to test case https://tigerspike.atlassian.net/browse/PSDK-21
// Refers to test case https://tigerspike.atlassian.net/browse/PSDK-22
class IntelligenceConfigurationTestCase: IntelligenceBaseTestCase {

    func testConfigurationFromFileAndBundle() {
        let bundle = Bundle(for: IntelligenceConfigurationTestCase.self)
        let cfg = genericConfiguration()
        do {
            let config = Intelligence.Configuration()
            try config.readFromFile(fileName: "config", inBundle: bundle)
            XCTAssert(config.clientID == cfg.clientID, "The client ID is incorrect")
            XCTAssert(config.clientSecret == cfg.clientSecret, "The client secret is incorrect")
            XCTAssert(config.region == cfg.region, "The region is incorrect")
            XCTAssert(config.environment == cfg.environment, "The environment is incorrect")
            XCTAssert(config.applicationID == cfg.applicationID, "The application Id is incorrect")
            XCTAssert(config.projectID == cfg.projectID, "The project Id is incorrect")
        } catch {
            // nop
            XCTAssert(false, "Couldn't read the file.")
        }
    }

    func genericConfiguration() -> Intelligence.Configuration {
        let configuration = Intelligence.Configuration()
        configuration.clientID = "CLIENT_ID" // as in file
        configuration.clientSecret = "CLIENT_SECRET" // as in file
        configuration.region = .singapore
        configuration.environment = .production

        configuration.applicationID = 10
        configuration.projectID = 20

        return configuration
    }

    func testFileNotFoundInReadFromFile() {
        let config = Intelligence.Configuration()

        do {
            try config.readFromFile(fileName: "Does not exist", inBundle: Bundle.main)
            XCTAssert(false, "File not found, but exception not thrown")
        } catch let err as ConfigurationError where err == .fileNotFoundError {
        } catch {
            XCTAssert(false, "Unexpected exception type.")
        }
    }

    func testFileInvalidFileConfiguration() {
        let config = Intelligence.Configuration()
        let bundle = Bundle(for: IntelligenceConfigurationTestCase.self)

        do {
            try config.readFromFile(fileName: "wrongjson", inBundle: bundle)
            XCTAssert(false, "File is invalid, but the exception is not thrown")
        } catch ConfigurationError.invalidFileError {
            // correct path
        } catch {
           XCTAssert(false, "Unexpected exception type.")
        }
    }

    func testFileMissingPropertyConfiguration() {
        let config = Intelligence.Configuration()
        let bundle = Bundle(for: IntelligenceConfigurationTestCase.self)

        do {
            try config.readFromFile(fileName: "missingproperty", inBundle: bundle)
            XCTAssert(false, "File has missing properties, but the exception is not thrown")
        } catch ConfigurationError.missingPropertyError {
            // correct path
        } catch {
            XCTAssert(false, "Unexpected exception type.")
        }
    }

    func testConfigurationIsValid() {
        let bundle = Bundle(for: IntelligenceConfigurationTestCase.self)
        do {
            let config = try Intelligence.Configuration(fromFile: "config", inBundle: bundle)
            XCTAssert(config.isValid, "The configuration provided is invalid")
        } catch {
            // nop
            XCTAssert(false, "Couldn't read the file.")
        }
    }

    func testConfigurationMissingPropertyError(_ cfg: Intelligence.Configuration) {
        XCTAssertFalse(cfg.isValid)
        XCTAssertTrue(cfg.hasMissingProperty)
        do {
            _ = try Intelligence(withDelegate: MockIntelligenceDelegate(), configuration: cfg, oauthProvider: mockOAuthProvider)
            XCTAssert(false, "No exception thrown")
        } catch ConfigurationError.missingPropertyError {
            // Correct path
            XCTAssertTrue(true)
        } catch {
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
        cfg.applicationID = 0
        testConfigurationMissingPropertyError(cfg)

        cfg = genericConfiguration()
        cfg.projectID = 0
        testConfigurationMissingPropertyError(cfg)

//        cfg = genericConfiguration()
//        cfg.region = nil
//        testConfigurationMissingPropertyError(cfg)
//        
//        cfg = genericConfiguration()
//        cfg.environment = nil
//        testConfigurationMissingPropertyError(cfg)
    }
}
