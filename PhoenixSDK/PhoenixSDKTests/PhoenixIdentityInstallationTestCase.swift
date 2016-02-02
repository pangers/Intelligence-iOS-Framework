//
//  IdentityModuleInstallationTestCase.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 17/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

// MARK: Fake Version Object

class VersionClass: PhoenixApplicationVersionProtocol {
    var fakeVersion: String = "1.0.1"
    var phx_applicationVersionString: String? {
        return fakeVersion
    }
}

// MARK: - Fake Storage Object

class InstallationStorage: InstallationStorageProtocol {
    var dictionary = [String: AnyObject]()
    var phx_applicationVersion: String? {
        return dictionary["appVer"] as? String
    }
    func phx_storeApplicationVersion(version: String?) {
        dictionary["appVer"] = version
    }
    var phx_isNewInstallation: Bool {
        return phx_applicationVersion == nil
    }
    func phx_isInstallationUpdated(applicationVersion: String?) -> Bool {
        guard let version = applicationVersion, stored = phx_applicationVersion else { return false }
        return version != stored // Assumption: any version change is considered an update
    }
    var phx_installationID: String? {
        return dictionary["installID"] as? String
    }
    func phx_storeInstallationID(newID: String?) {
        dictionary["installID"] = newID
    }
    var phx_installationRequestID: Int? {
        return dictionary["requestID"] as? Int
    }
    func phx_storeInstallationRequestID(newID: Int?) {
        dictionary["requestID"] = newID
    }
    var phx_installationCreateDateString: String? {
        return dictionary["date"] as? String
    }
    func phx_storeInstallationCreateDate(newDate: String?) {
        dictionary["date"] = newDate
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
            appID = json[Installation.ApplicationId] as? Int,
            installed = json[Installation.InstalledVersion] as? String,
            OSVer = json[Installation.OperatingSystemVersion] as? String
            where projectID == 20 &&
                appID == 10 &&
                OSVer == UIDevice.currentDevice().systemVersion &&
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
        
        let URL = NSURLRequest.phx_URLRequestForInstallationCreate(mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).URL!
        
        mockResponseForURL(URL,
            method: .POST,
            response: (data: successfulInstallationResponse, statusCode:.NotFound, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        
        identity?.createInstallation() { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error!.code == RequestError.UnhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error!.httpStatusCode() == HTTPStatusCode.NotFound.rawValue, "Expected a NotFound (404) error")
            expectation.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateInstallationParseFailure() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForCreateInstallation()
        
        let URL = NSURLRequest.phx_URLRequestForInstallationCreate(mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).URL!
        
        mockResponseForURL(URL,
            method: .POST,
            response: (data: failedInstallationResponse, statusCode: .Success, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        identity?.createInstallation() { (installation, error) -> Void in
            XCTAssertNotNil(error, "Expected error")
            XCTAssert(error?.code == RequestError.ParseError.rawValue, "Expected parse error")
            expectation.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateInstallationUnnecessary() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForCreateInstallation()
        
        // Mock installation request
        let jsonData = successfulInstallationResponse.dataUsingEncoding(NSUTF8StringEncoding)!.phx_jsonDictionary!["Data"] as! JSONDictionaryArray
        let data = jsonData.first!
        mockInstallation.updateWithJSON(data)
        
        XCTAssert(mockInstallation.isNewInstallation == false, "Should not be new installation")
        
        let URL = NSURLRequest.phx_URLRequestForInstallationCreate(mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).URL!
        
        assertURLNotCalled(URL)
        
        identity?.createInstallation() { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error!.code == InstallationError.AlreadyInstalledError.rawValue, "Expected create error")
        }
    }
    
    // MARK: - Update Installation
    
    func mockPrepareForCreateInstallation() {
        let installation = mockInstallation
        
        XCTAssert(installation.isUpdatedInstallation == false, "Should not be updated installation")
        XCTAssert(installation.isNewInstallation == true, "Should be new installation")
        XCTAssert(installation.toJSON()[Installation.ProjectId] as! Int == mockConfiguration.projectID, "Project ID must match configuration")
        XCTAssert(installation.toJSON()[Installation.ApplicationId] as! Int == mockConfiguration.applicationID, "Application ID must match configuration")
        XCTAssert(installation.toJSON()[Installation.Id] as? String == nil, "ID must be nil")
        XCTAssert(installation.toJSON()[Installation.CreateDate] as? String == nil, "Create date must be nil")
        XCTAssert(installation.toJSON()[Installation.InstalledVersion] as? String == "1.0.1", "Installation version must be 1.0.1")
        XCTAssert(installation.toJSON()[Installation.DeviceTypeId] as? Int == 1, "Device type must be 1 (Smartphone)")
        XCTAssert(installation.toJSON()[Installation.OperatingSystemVersion] as? String == UIDevice.currentDevice().systemVersion, "OS must be \(UIDevice.currentDevice().systemVersion)")
    }
    
    func mockPrepareForUpdateInstallation() {
        var installation = mockInstallation
        
        mockPrepareForCreateInstallation()
        
        // Mock installation request
        let jsonData = (successfulInstallationResponse.dataUsingEncoding(NSUTF8StringEncoding)!.phx_jsonDictionary!["Data"] as! JSONDictionaryArray).first!
        installation.updateWithJSON(jsonData)
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
        
        let URL = NSURLRequest.phx_URLRequestForInstallationUpdate(mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).URL
        
        mockResponseForURL(URL,
            method: .PUT,
            response: (data: successfulInstallationUpdateResponse, statusCode: .Success, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        identity?.updateInstallation() { (installation, error) -> Void in
            XCTAssert(error == nil, "Unexpected error")
            
            let json = self.mockInstallation.toJSON()
            if let id = json[Installation.Id] as? Int,
                installed = json[Installation.InstalledVersion] as? String,
                OSVer = json[Installation.OperatingSystemVersion] as? String
                where OSVer == UIDevice.currentDevice().systemVersion &&
                    installed == "1.0.2" &&
                    id == 1054 {
                        XCTAssert(true)
            } else {
                XCTAssert(false)
            }
            
            XCTAssert(self.mockInstallation.isUpdatedInstallation == false)
            expectation.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testUpdateInstallationFailure() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForUpdateInstallation()
        
        let URL = NSURLRequest.phx_URLRequestForInstallationUpdate(mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).URL
        
        mockResponseForURL(URL,
            method:.PUT,
            response: (data: successfulInstallationUpdateResponse, statusCode:.NotFound, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        identity?.updateInstallation() { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error!.code == RequestError.UnhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error!.httpStatusCode() == HTTPStatusCode.NotFound.rawValue, "Expected a NotFound (404) error")
            expectation.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testUpdateInstallationParseFailure() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForUpdateInstallation()
        
        let URL = NSURLRequest.phx_URLRequestForInstallationUpdate(mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).URL
        
        mockResponseForURL(URL,
            method: .PUT,
            response: (data: failedInstallationResponse, statusCode: .Success, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        identity?.updateInstallation() { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error!.code == RequestError.ParseError.rawValue, "Expected parse error")
            expectation.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testUpdateInstallationUnnecessary() {
        // Mock request being authorized
        let oauth = mockOAuthProvider.sdkUserOAuth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockPrepareForUpdateInstallation()
        
        let jsonData = (successfulInstallationUpdateResponse.dataUsingEncoding(NSUTF8StringEncoding)!.phx_jsonDictionary!["Data"] as! JSONDictionaryArray).first!
        mockInstallation.updateWithJSON(jsonData)
        XCTAssert(mockInstallation.isUpdatedInstallation == false, "Should not be updated version")
        
        
        let URL = NSURLRequest.phx_URLRequestForInstallationUpdate(mockInstallation, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).URL!
        assertURLNotCalled(URL)
        
        identity?.updateInstallation() { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error?.code == InstallationError.AlreadyUpdatedError.rawValue, "Expected update error")
        }
    }
}