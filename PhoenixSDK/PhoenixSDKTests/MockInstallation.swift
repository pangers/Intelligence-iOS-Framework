//
//  MockInstallation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class MockPhoenixInstallation {
    
    class func newInstance(configuration: Phoenix.Configuration, storage: PhoenixInstallationStorageProtocol) -> Phoenix.Installation {
        let installation = Phoenix.Installation(configuration: configuration, applicationVersion: VersionClass(), installationStorage: storage)
        XCTAssert(installation.isUpdatedInstallation == false, "Should not be updated installation")
        XCTAssert(installation.isNewInstallation == true, "Should be new installation")
        XCTAssert(installation.toJSON()[Phoenix.Installation.ProjectId] as! Int == configuration.projectID, "Project ID must match configuration")
        XCTAssert(installation.toJSON()[Phoenix.Installation.ApplicationId] as! Int == configuration.applicationID, "Application ID must match configuration")
        XCTAssert(installation.toJSON()[Phoenix.Installation.InstallationId] as! String == InstallationStorage.phoenixInstallationDefaultCreateID, "Installation ID must match default ID")
        XCTAssert(installation.toJSON()[Phoenix.Installation.RequestId] as? String == nil, "Request ID must be nil")
        XCTAssert(installation.toJSON()[Phoenix.Installation.CreateDate] as? String == nil, "Create date must be nil")
        XCTAssert(installation.toJSON()[Phoenix.Installation.InstalledVersion] as? String == "1.0.1", "Installation version must be 1.0.1")
        XCTAssert(installation.toJSON()[Phoenix.Installation.DeviceTypeId] as? String == "Smartphone", "Device type must be Smartphone")
        XCTAssert(installation.toJSON()[Phoenix.Installation.OperatingSystemVersion] as? String == UIDevice.currentDevice().systemVersion, "OS must be \(UIDevice.currentDevice().systemVersion)")
        XCTAssert(installation.toJSON()[Phoenix.Installation.ModelReference] as? String == UIDevice.currentDevice().model, "Device type must be \(UIDevice.currentDevice().model)")
        return installation
    }
    
}