//
//  MockInstallation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class MockInstallation {
    
    class func newInstance(configuration: Phoenix.Configuration, storage: InstallationStorageProtocol) -> Installation {
        let installation = Installation(configuration: configuration, applicationVersion: VersionClass(), installationStorage: storage)
        XCTAssert(installation.isUpdatedInstallation == false, "Should not be updated installation")
        XCTAssert(installation.isNewInstallation == true, "Should be new installation")
        XCTAssert(installation.toJSON()[Installation.ProjectId] as! Int == configuration.projectID, "Project ID must match configuration")
        XCTAssert(installation.toJSON()[Installation.ApplicationId] as! Int == configuration.applicationID, "Application ID must match configuration")
        XCTAssert(installation.toJSON()[Installation.InstallationId] as! String == InstallationStorage.phoenixInstallationDefaultCreateID, "Installation ID must match default ID")
        XCTAssert(installation.toJSON()[Installation.RequestId] as? String == nil, "Request ID must be nil")
        XCTAssert(installation.toJSON()[Installation.CreateDate] as? String == nil, "Create date must be nil")
        XCTAssert(installation.toJSON()[Installation.InstalledVersion] as? String == "1.0.1", "Installation version must be 1.0.1")
        XCTAssert(installation.toJSON()[Installation.DeviceTypeId] as? String == "Smartphone", "Device type must be Smartphone")
        XCTAssert(installation.toJSON()[Installation.OperatingSystemVersion] as? String == UIDevice.currentDevice().systemVersion, "OS must be \(UIDevice.currentDevice().systemVersion)")
        XCTAssert(installation.toJSON()[Installation.ModelReference] as? String == UIDevice.currentDevice().model, "Device type must be \(UIDevice.currentDevice().model)")
        return installation
    }
    
}