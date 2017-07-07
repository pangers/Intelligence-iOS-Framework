//
//  MockInstallation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK

class MockInstallation {
    
    class func newInstance(_ configuration: Intelligence.Configuration, storage: InstallationStorageProtocol, oauthProvider: IntelligenceOAuthProvider) -> Installation {
        let installation = Installation(configuration: configuration, applicationVersion: VersionClass(), installationStorage: storage, oauthProvider: oauthProvider)
        XCTAssert(installation.isUpdatedInstallation == false, "Should not be updated installation")
        XCTAssert(installation.isNewInstallation == true, "Should be new installation")
        XCTAssert(installation.toJSON()[Installation.ProjectId] as! Int == configuration.projectID, "Project ID must match configuration")
        XCTAssert(installation.toJSON()[Installation.ApplicationId] as! Int == configuration.applicationID, "Application ID must match configuration")
        XCTAssert(installation.toJSON()[Installation.Id] as? String == nil, "ID must be nil")
        XCTAssert(installation.toJSON()[Installation.CreateDate] as? String == nil, "Create date must be nil")
        XCTAssert(installation.toJSON()[Installation.InstalledVersion] as? String == "1.0.1", "Installation version must be 1.0.1")
        XCTAssert(installation.toJSON()[Installation.DeviceTypeId] as? Int == 1, "Device type must be 1 (Smartphone)")
        XCTAssert(installation.toJSON()[Installation.OperatingSystemVersion] as? String == UIDevice.current.systemVersion, "OS must be \(UIDevice.current.systemVersion)")
        return installation
    }
    
}
