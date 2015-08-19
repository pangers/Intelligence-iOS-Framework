//
//  PhoenixIdentityInstallationTestCase.swift
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

class InstallationStorage: PhoenixInstallationStorageProtocol {
    static let phoenixInstallationDefaultCreateID = "00000000-0000-0000-0000-000000000000"
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
        return dictionary["installID"] as? String ?? InstallationStorage.phoenixInstallationDefaultCreateID
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

class PhoenixIdentityInstallationTestCase: PhoenixIdentityTestCase {
    
    // Version 1.0.1
    let successfulInstallationResponse = "{" +
        "\"TotalRecords\": 1," +
        "\"Data\": [{" +
        "\"Id\": 1054," +
        "\"ProjectId\": 20," +
        "\"ApplicationId\": 10," +
        "\"InstalledVersion\": \"1.0.1\"," +
        "\"InstallationId\": \"bc1512a8-f0d3-4f91-a9c3-53af39667431\"," +
        "\"DeviceTypeId\": \"Smartphone\"," +
        "\"CreateDate\": \"2015-08-14T10:06:13.3850765Z\"," +
        "\"ModifyDate\": \"2015-08-14T10:06:13.3850765Z\"," +
        "\"OperatingSystemVersion\": \"9.0\"," +
        "\"ModelReference\": \"iPhone\"" +
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
        "\"DeviceTypeId\": \"Smartphone\"," +
        "\"CreateDate\": \"2015-08-14T10:06:13.3850765Z\"," +
        "\"ModifyDate\": \"2015-08-14T10:06:13.3850765Z\"," +
        "\"OperatingSystemVersion\": \"9.0\"," +
        "\"ModelReference\": \"iPhone\"" +
        "}]" +
    "}"
    
    // Generic failure
    let failedInstallationResponse = "{[fail;)]}"
    
    
    // MARK:- Create Installation
    
    func prepareValidCreateInstallationObject() -> Phoenix.Installation {
        let installation = Phoenix.Installation(configuration: configuration!, version: VersionClass(), storage: InstallationStorage())
        XCTAssert(installation.isUpdatedInstallation == false, "Should not be updated installation")
        XCTAssert(installation.isNewInstallation == true, "Should be new installation")
        XCTAssert(installation.toJSON()[Phoenix.Installation.ProjectId] as! Int == configuration!.projectID, "Project ID must match configuration")
        XCTAssert(installation.toJSON()[Phoenix.Installation.ApplicationId] as! Int == configuration!.applicationID, "Application ID must match configuration")
        XCTAssert(installation.toJSON()[Phoenix.Installation.InstallationId] as! String == InstallationStorage.phoenixInstallationDefaultCreateID, "Installation ID must match default ID")
        XCTAssert(installation.toJSON()[Phoenix.Installation.RequestId] as? String == nil, "Request ID must be nil")
        XCTAssert(installation.toJSON()[Phoenix.Installation.CreateDate] as? String == nil, "Create date must be nil")
        XCTAssert(installation.toJSON()[Phoenix.Installation.InstalledVersion] as? String == "1.0.1", "Installation version must be 1.0.1")
        XCTAssert(installation.toJSON()[Phoenix.Installation.DeviceTypeId] as? String == "Smartphone", "Device type must be Smartphone")
        XCTAssert(installation.toJSON()[Phoenix.Installation.OperatingSystemVersion] as? String == "9.0", "OS must be 9.0")
        XCTAssert(installation.toJSON()[Phoenix.Installation.ModelReference] as? String == "iPhone", "Device type must be iPhone")
        return installation
    }
    
    func testCreateInstallationSuccess() {
        // Mock request being authorized
        mockValidTokenStorage()
        
        let installation = prepareValidCreateInstallationObject()
        
        let request = NSURLRequest.phx_httpURLRequestForCreateInstallation(installation).URL!
        
        mockResponseForURL(request,
            method: "POST",
            response: (data: successfulInstallationResponse, statusCode:200, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        identity?.createInstallation(installation) { (installation, error) -> Void in
            XCTAssert(error == nil, "Unexpected error")
            let json = installation.toJSON()
            if let projectID = json[Phoenix.Installation.ProjectId] as? Int,
                appID = json[Phoenix.Installation.ApplicationId] as? Int,
                installationID = json[Phoenix.Installation.InstallationId] as? String,
                id = json[Phoenix.Installation.RequestId] as? Int,
                createDate = json[Phoenix.Installation.CreateDate] as? String,
                modelRef = json[Phoenix.Installation.ModelReference] as? String,
                installed = json[Phoenix.Installation.InstalledVersion] as? String,
                OSVer = json[Phoenix.Installation.OperatingSystemVersion] as? String
                where projectID == 20 &&
                    appID == 10 &&
                    OSVer == "9.0" &&
                    installationID == "bc1512a8-f0d3-4f91-a9c3-53af39667431" &&
                    modelRef == "iPhone" &&
                    installed == "1.0.1" &&
                    id == 1054 &&
                    createDate == "2015-08-14T10:06:13.3850765Z" {
                        XCTAssert(true)
            } else {
                XCTAssert(false)
            }
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    func testCreateInstallationFailure() {
        mockValidTokenStorage()
        
        let installation = Phoenix.Installation(configuration: configuration!, version: VersionClass(), storage: InstallationStorage())
        
        let request = NSURLRequest.phx_httpURLRequestForCreateInstallation(installation).URL!
        
        mockResponseForURL(request,
            method: "POST",
            response: (data: successfulInstallationResponse, statusCode:404, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        identity?.createInstallation(installation) { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error?.code == RequestError.RequestFailedError.rawValue, "Expected wrapped 4001 error")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    func testCreateInstallationParseFailure() {
        // Mock request being authorized
        mockValidTokenStorage()
        
        let installation = prepareValidCreateInstallationObject()
        
        let request = NSURLRequest.phx_httpURLRequestForCreateInstallation(installation).URL!
        
        mockResponseForURL(request,
            method: "POST",
            response: (data: failedInstallationResponse, statusCode:200, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        identity?.createInstallation(installation) { (installation, error) -> Void in
            XCTAssertNotNil(error, "Expected error")
            XCTAssert(error?.code == RequestError.ParseError.rawValue, "Expected parse error")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    func testCreateInstallationUnnecessary() {
        mockValidTokenStorage()
        
        // Mock installation request
        let storage = InstallationStorage()
        let version = VersionClass()
        var installation = Phoenix.Installation(configuration: configuration!, version: version, storage: storage)
        
        let jsonData = successfulInstallationResponse.dataUsingEncoding(NSUTF8StringEncoding)!.phx_jsonDictionary!["Data"] as! JSONDictionaryArray
        let data = jsonData.first!
        installation.updateWithJSON(data)
        
        XCTAssert(installation.isNewInstallation == false, "Should not be new installation")
        
        let request = NSURLRequest.phx_httpURLRequestForCreateInstallation(installation).URL!
        assertURLNotCalled(request)
        
        identity?.createInstallation(installation) { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error?.code == InstallationError.AlreadyInstalled.rawValue, "Expected create error")
        }
    }
    
    // MARK: - Update Installation
    
    func prepareValidUpdateInstallationObject() -> Phoenix.Installation {
        var installation = prepareValidCreateInstallationObject()
        
        // Mock installation request
        let jsonData = (successfulInstallationResponse.dataUsingEncoding(NSUTF8StringEncoding)!.phx_jsonDictionary!["Data"] as! JSONDictionaryArray).first!
        installation.updateWithJSON(jsonData)
        XCTAssert(installation.isNewInstallation == false, "Should not be new installation")
        
        (installation.version as? VersionClass)?.fakeVersion = "1.0.2"
        installation = Phoenix.Installation(configuration: configuration!, version: installation.version, storage: installation.storage)
        XCTAssert(installation.isUpdatedInstallation == true, "Should be updated version")
        XCTAssert(installation.toJSON()[Phoenix.Installation.CreateDate] != nil, "Create date must be set")
        XCTAssert(installation.toJSON()[Phoenix.Installation.RequestId] != nil, "Request ID must be set")
        return installation
    }
    
    func testUpdateInstallationSuccess() {
        // Mock request being authorized
        mockValidTokenStorage()
        
        let installation = prepareValidUpdateInstallationObject()
        
        mockResponseForURL(NSURLRequest.phx_httpURLRequestForUpdateInstallation(installation).URL!,
            method: "PUT",
            response: (data: successfulInstallationUpdateResponse, statusCode:200, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        identity?.updateInstallation(installation) { (installation, error) -> Void in
            XCTAssert(error == nil, "Unexpected error")
            let json = installation.toJSON()
            if let projectID = json[Phoenix.Installation.ProjectId] as? Int,
                appID = json[Phoenix.Installation.ApplicationId] as? Int,
                installationID = json[Phoenix.Installation.InstallationId] as? String,
                id = json[Phoenix.Installation.RequestId] as? Int,
                createDate = json[Phoenix.Installation.CreateDate] as? String,
                modelRef = json[Phoenix.Installation.ModelReference] as? String,
                installed = json[Phoenix.Installation.InstalledVersion] as? String,
                OSVer = json[Phoenix.Installation.OperatingSystemVersion] as? String
                where projectID == 20 &&
                    appID == 10 &&
                    OSVer == "9.0" &&
                    installationID == "bc1512a8-f0d3-4f91-a9c3-53af39667431" &&
                    modelRef == "iPhone" &&
                    installed == "1.0.2" &&
                    id == 1054 &&
                    createDate == "2015-08-14T10:06:13.3850765Z" {
                        XCTAssert(true)
            } else {
                XCTAssert(false)
            }
            XCTAssert(installation.isUpdatedInstallation == false)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    func testUpdateInstallationFailure() {
        mockValidTokenStorage()
        
        let installation = prepareValidUpdateInstallationObject()
        
        let request = NSURLRequest.phx_httpURLRequestForUpdateInstallation(installation).URL!
        
        mockResponseForURL(request,
            method: "PUT",
            response: (data: successfulInstallationUpdateResponse, statusCode:404, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        identity?.updateInstallation(installation) { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error?.code == RequestError.RequestFailedError.rawValue, "Expected wrapped 4001 error")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    func testUpdateInstallationParseFailure() {
        mockValidTokenStorage()
        
        let installation = prepareValidUpdateInstallationObject()
        
        let request = NSURLRequest.phx_httpURLRequestForUpdateInstallation(installation).URL!
        
        mockResponseForURL(request,
            method: "PUT",
            response: (data: failedInstallationResponse, statusCode:200, headers:nil))
        
        let expectation = expectationWithDescription("Was expecting a callback to be notified")
        identity?.updateInstallation(installation) { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error?.code == RequestError.ParseError.rawValue, "Expected parse error")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    func testUpdateInstallationUnnecessary() {
        mockValidTokenStorage()
        
        let installation = prepareValidUpdateInstallationObject()
        let jsonData = (successfulInstallationUpdateResponse.dataUsingEncoding(NSUTF8StringEncoding)!.phx_jsonDictionary!["Data"] as! JSONDictionaryArray).first!
        installation.updateWithJSON(jsonData)
        XCTAssert(installation.isUpdatedInstallation == false, "Should not be updated version")
        
        let request = NSURLRequest.phx_httpURLRequestForUpdateInstallation(installation).URL!
        assertURLNotCalled(request)
        
        identity?.updateInstallation(installation) { (installation, error) -> Void in
            XCTAssert(error != nil, "Expected error")
            XCTAssert(error?.code == InstallationError.AlreadyUpdated.rawValue, "Expected update error")
        }
    }
}