//
//  IdentityModuleInstallationTestCase.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 17/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK

// MARK: Fake Version Object

class VersionClass: IntelligenceApplicationVersionProtocol {
    var fakeVersion: String = "1.0.1"
    var int_applicationVersionString: String? {
        return fakeVersion
    }
}

// MARK: - Fake Storage Object

class InstallationStorage: InstallationStorageProtocol {
    var dictionary = [String: AnyObject]()
    var int_applicationVersion: String? {
        return dictionary["appVer"] as? String
    }
    func int_storeApplicationVersion(version: String?) {
        dictionary["appVer"] = version as AnyObject?
    }
    var int_isNewInstallation: Bool {
        return int_applicationVersion == nil
    }
    func int_isInstallationUpdated(applicationVersion: String?) -> Bool {
        guard let version = applicationVersion, let stored = int_applicationVersion else { return false }
        return version != stored // Assumption: any version change is considered an update
    }
    var int_installationID: String? {
        return dictionary["installID"] as? String
    }
    func int_storeInstallationID(newID: String?) {
        dictionary["installID"] = newID as AnyObject?
    }
    var int_installationRequestID: Int? {
        return dictionary["requestID"] as? Int
    }
    func int_storeInstallationRequestID(newID: Int?) {
        dictionary["requestID"] = newID as AnyObject?
    }
    var int_installationCreateDateString: String? {
        return dictionary["date"] as? String
    }
    func int_storeInstallationCreateDate(newDate: String?) {
        dictionary["date"] = newDate as AnyObject?
    }
}

class IdentityModuleInstallationTestCase: IdentityModuleTestCase {
    
    // Version 1.0.1
    let successfulInstallationResponse = "{" +
        "\"TotalRecords\": 1," +
        "\"Data\": [{" +
        "\"Id\": 1054," +
        "\"ProjectId\": 20," +
        "\"ApplicationId\": 10," +
        "\"InstalledVersion\": \"1.0.1\"," +
        "\"InstallationId\": \"bc1512a8-f0d3-4f91-a9c3-53af39667431\"," +
        "\"DeviceTypeId\": 1," +
        "\"DateCreated\": \"2015-08-14T10:06:13.3850765Z\"," +
        "\"DateUpdated\": \"2015-08-14T10:06:13.3850765Z\"," +
        "\"OperatingSystemVersion\": \"9.0\"," +
        "}]" +
    "}"
    
    // Version 1.0.2
    let successfulInstallationUpdateResponse = "{" +
        "\"TotalRecords\": 1," +
        "\"Data\": [{" +
        "\"Id\": 1054," +
        "\"ProjectId\": 20," +
        "\"ApplicationId\": 10," +
        "\"InstalledVersion\": \"1.0.2\"," +
        "\"InstallationId\": \"bc1512a8-f0d3-4f91-a9c3-53af39667431\"," +
        "\"DeviceTypeId\": 1," +
        "\"DateCreated\": \"2015-08-14T10:06:13.3850765Z\"," +
        "\"DateUpdated\": \"2015-08-14T10:06:13.3850765Z\"," +
        "\"OperatingSystemVersion\": \"9.0\"," +
        "}]" +
    "}"
    
    // Generic failure
    let failedInstallationResponse = "{[fail;)]}"
    
    
    // MARK:- Create Installation
    
    func testCreateInstallationSuccess() {
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForCreateInstallation()
        
        guard let json = mockInstallation?.toJSON() else {
            XCTFail()
            return
        }
        
        if let projectID = json[Installation.ProjectId] as? Int,
            let appID = json[Installation.ApplicationId] as? Int,
            let installed = json[Installation.InstalledVersion] as? String,
            let OSVer = json[Installation.OperatingSystemVersion] as? String
            , projectID == 20 &&
                appID == 10 &&
                OSVer == UIDevice.current.systemVersion &&
                installed == "1.0.1" {
                    XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
    
    func testCreateInstallationFailure() {
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForCreateInstallation()
        
        let URL = URLRequest.int_URLRequestForInstallationCreate(installation: mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).url!
        
        mockResponseForURL(URL,
                           method: .post,
                           response: (data: successfulInstallationResponse, statusCode:.notFound, headers:nil))
        
        let testExpectation = expectation(description: "Was expecting a callback to be notified")
        identity?.createInstallation() { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error!.code == RequestError.unhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error!.httpStatusCode() == HTTPStatusCode.notFound.rawValue, "Expected a NotFound (404) error")
            testExpectation.fulfill()
        }
        waitForExpectations()
    }
    
    func testCreateInstallationParseFailure() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForCreateInstallation()
        
        let URL = URLRequest.int_URLRequestForInstallationCreate(installation: mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).url!
        
        mockResponseForURL(URL,
                           method: .post,
                           response: (data: failedInstallationResponse, statusCode: .success, headers:nil))
        
        let testExpectation = expectation(description: "Was expecting a callback to be notified")
        identity?.createInstallation() { (installation, error) -> Void in
            XCTAssertNotNil(error, "Expected error")
            XCTAssert(error?.code == RequestError.parseError.rawValue, "Expected parse error")
            testExpectation.fulfill()
        }
        waitForExpectations()
    }
    
    func testCreateInstallationUnnecessary() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForCreateInstallation()
        
        // Mock installation request
        let jsonData = successfulInstallationResponse.data(using: String.Encoding.utf8)!.int_jsonDictionary!["Data"] as! JSONDictionaryArray
        let data = jsonData.first!
        _ = mockInstallation.updateWithJSON(json: data)
        
        XCTAssert(mockInstallation.isNewInstallation == false, "Should not be new installation")
        
        let URL = URLRequest.int_URLRequestForInstallationCreate(installation: mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).url!
        
        assertURLNotCalled(URL)
        
        identity?.createInstallation() { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error!.code == InstallationError.alreadyInstalledError.rawValue, "Expected create error")
        }
    }
    
    // MARK: - Update Installation
    
    func mockPrepareForCreateInstallation() {
        guard let installation = mockInstallation else{
            return
        }
        
        XCTAssert(installation.isUpdatedInstallation == false, "Should not be updated installation")
        XCTAssert(installation.isNewInstallation == true, "Should be new installation")
        XCTAssert(installation.toJSON()[Installation.ProjectId] as! Int == mockConfiguration.projectID, "Project ID must match configuration")
        XCTAssert(installation.toJSON()[Installation.ApplicationId] as! Int == mockConfiguration.applicationID, "Application ID must match configuration")
        XCTAssert(installation.toJSON()[Installation.Id] as? String == nil, "ID must be nil")
        XCTAssert(installation.toJSON()[Installation.CreateDate] as? String == nil, "Create date must be nil")
        XCTAssert(installation.toJSON()[Installation.InstalledVersion] as? String == "1.0.1", "Installation version must be 1.0.1")
        XCTAssert(installation.toJSON()[Installation.DeviceTypeId] as? Int == 1, "Device type must be 1 (Smartphone)")
        XCTAssert(installation.toJSON()[Installation.OperatingSystemVersion] as? String == UIDevice.current.systemVersion, "OS must be \(UIDevice.current.systemVersion)")
    }
    
    func mockPrepareForUpdateInstallation() {
        guard var installation = mockInstallation else {
            return
        }
        
        mockPrepareForCreateInstallation()
        
        // Mock installation request
        let jsonData = (successfulInstallationResponse.data(using: String.Encoding.utf8)!.int_jsonDictionary!["Data"] as! JSONDictionaryArray).first!
        _ = installation.updateWithJSON(json: jsonData)
        XCTAssert(installation.isNewInstallation == false, "Should not be new installation")
        
        (installation.applicationVersion as? VersionClass)?.fakeVersion = "1.0.2"
        installation = Installation(configuration: mockConfiguration, applicationVersion: installation.applicationVersion, installationStorage: installation.installationStorage, oauthProvider: installation.oauthProvider)
        XCTAssert(installation.isUpdatedInstallation == true, "Should be updated version")
        XCTAssert(installation.toJSON()[Installation.Id] != nil, "ID must be set")
        XCTAssert(installation.isValidToUpdate)
    }
    
    func testUpdateInstallationSuccess() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForUpdateInstallation()
        
        let URL = URLRequest.int_URLRequestForInstallationUpdate(installation: mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).url
        
        mockResponseForURL(URL,
                           method: .put,
                           response: (data: successfulInstallationUpdateResponse, statusCode: .success, headers:nil))
        
        let testExpectation = expectation(description: "Was expecting a callback to be notified")
       
        identity?.updateInstallation() { (installation, error) -> Void in
            XCTAssert(error == nil, "Unexpected error")
            
            let json = self.mockInstallation.toJSON()
            if let id = json[Installation.Id] as? Int,
                let installed = json[Installation.InstalledVersion] as? String,
                let OSVer = json[Installation.OperatingSystemVersion] as? String
                , OSVer == UIDevice.current.systemVersion &&
                    installed == "1.0.2" &&
                    id == 1054 {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
            
            XCTAssert(self.mockInstallation.isUpdatedInstallation == false)
            testExpectation.fulfill()
        }
        waitForExpectations()
    }
    
    func testUpdateInstallationFailure() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForUpdateInstallation()
        
        let URL = URLRequest.int_URLRequestForInstallationUpdate(installation: mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).url
        
        mockResponseForURL(URL,
            method:.put,
            response: (data: successfulInstallationUpdateResponse, statusCode:.notFound, headers:nil))
        
        let testExpectation = expectation(description: "Was expecting a callback to be notified")
        identity?.updateInstallation() { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error!.code == RequestError.unhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error!.httpStatusCode() == HTTPStatusCode.notFound.rawValue, "Expected a NotFound (404) error")
            testExpectation.fulfill()
        }
        waitForExpectations()
    }
    
    func testUpdateInstallationParseFailure() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForUpdateInstallation()
        
        let URL = URLRequest.int_URLRequestForInstallationUpdate(installation: mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).url
        
        mockResponseForURL(URL,
                           method: .put,
                           response: (data: failedInstallationResponse, statusCode: .success, headers:nil))
        
        let testExpectation = expectation(description: "Was expecting a callback to be notified")
        identity?.updateInstallation() { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error!.code == RequestError.parseError.rawValue, "Expected parse error")
            testExpectation.fulfill()
        }
        waitForExpectations()
    }
    
    func testUpdateInstallationUnnecessary() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForUpdateInstallation()
        
        let jsonData = (successfulInstallationUpdateResponse.data(using: String.Encoding.utf8)!.int_jsonDictionary!["Data"] as! JSONDictionaryArray).first!
        _ = mockInstallation.updateWithJSON(json: jsonData)
        XCTAssert(mockInstallation.isUpdatedInstallation == false, "Should not be updated version")
        
        
        let URL = URLRequest.int_URLRequestForInstallationUpdate(installation: mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).url!
        assertURLNotCalled(URL)
        
        identity?.updateInstallation() { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error?.code == InstallationError.alreadyUpdatedError.rawValue, "Expected update error")
        }
    }
}
