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
    
    class func newInstance(configuration: Phoenix.Configuration, storage: PhoenixInstallationStorageProtocol) -> PhoenixInstallation {
        let installation = PhoenixInstallation(configuration: configuration, applicationVersion: VersionClass(), installationStorage: storage)
        XCTAssert(installation.isUpdatedInstallation == false, "Should not be updated installation")
        XCTAssert(installation.isNewInstallation == true, "Should be new installation")
        XCTAssert(installation.toJSON()[PhoenixInstallation.ProjectId] as! Int == configuration.projectID, "Project ID must match configuration")
        XCTAssert(installation.toJSON()[PhoenixInstallation.ApplicationId] as! Int == configuration.applicationID, "Application ID must match configuration")
        XCTAssert(installation.toJSON()[PhoenixInstallation.InstallationId] as! String == InstallationStorage.phoenixInstallationDefaultCreateID, "Installation ID must match default ID")
        XCTAssert(installation.toJSON()[PhoenixInstallation.RequestId] as? String == nil, "Request ID must be nil")
        XCTAssert(installation.toJSON()[PhoenixInstallation.CreateDate] as? String == nil, "Create date must be nil")
        XCTAssert(installation.toJSON()[PhoenixInstallation.InstalledVersion] as? String == "1.0.1", "Installation version must be 1.0.1")
        XCTAssert(installation.toJSON()[PhoenixInstallation.DeviceTypeId] as? String == "Smartphone", "Device type must be Smartphone")
        XCTAssert(installation.toJSON()[PhoenixInstallation.OperatingSystemVersion] as? String == UIDevice.currentDevice().systemVersion, "OS must be \(UIDevice.currentDevice().systemVersion)")
        XCTAssert(installation.toJSON()[PhoenixInstallation.ModelReference] as? String == UIDevice.currentDevice().model, "Device type must be \(UIDevice.currentDevice().model)")
        return installation
    }
    
}