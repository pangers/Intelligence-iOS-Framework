//
//  NSUserDefaultsInstallation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal protocol InstallationStorageProtocol {
    /// - Returns: Stored application version or nil.
    var phx_applicationVersion: String? {get}
    /// Store current app version.
    func phx_storeApplicationVersion(version: String?)
    /// - Returns: True if fresh installation.
    var phx_isNewInstallation: Bool {get}
    /// - Returns: False if we cannot get stored app version or current app version.
    func phx_isInstallationUpdated(applicationVersion: String?) -> Bool
    /// - Returns: Previous installation ID or zeros.
    var phx_installationID: String? {get}
    /// Stores installation ID that was returned by the server.
    func phx_storeInstallationID(newID: String?)
    /// - Returns: Previous request ID.
    var phx_installationRequestID: Int? {get}
    /// Stores request ID that was returned by the server.
    func phx_storeInstallationRequestID(newID: Int?)
    /// Intelligence currently requires us to send the creation date, otherwise it will update it to the current date.
    /// - Returns: Creation date of previous request.
    var phx_installationCreateDateString: String? {get}
    /// Stores create date that was returned by the server.
    func phx_storeInstallationCreateDate(newDate: String?)
}

private let intelligenceAppVersionKey = "IntelligenceAppVersion"
private let intelligenceInstallationIDKey = "InstallationID"
private let intelligenceInstallationCreateDateKey = "InstallationCreateDate"
private let intelligenceInstallationRequestIDKey = "InstallationRequestID"

extension NSUserDefaults: InstallationStorageProtocol {
    
    // MARK:- App Version
    var phx_applicationVersion: String? {
        return objectForKey(intelligenceAppVersionKey) as? String
    }
    
    func phx_storeApplicationVersion(version: String?) {
        setObject(version, forKey: intelligenceAppVersionKey)
        synchronize()
    }
    
    var phx_isNewInstallation: Bool {
        return phx_applicationVersion == nil
    }
    
    func phx_isInstallationUpdated(applicationVersion: String?) -> Bool {
        guard let version = applicationVersion, stored = phx_applicationVersion else { return false }
        return version != stored // Assumption: any version change is considered an update
    }
    
    // MARK:- Installation ID
    
    var phx_installationID: String? {
        return objectForKey(intelligenceInstallationIDKey) as? String
    }
    
    func phx_storeInstallationID(newID: String?) {
        setObject(newID, forKey: intelligenceInstallationIDKey)
        synchronize()
    }
    
    // MARK:- Request ID
    
    var phx_installationRequestID: Int? {
        return objectForKey(intelligenceInstallationRequestIDKey) as? Int
    }
    
    func phx_storeInstallationRequestID(newID: Int?) {
        setObject(newID, forKey: intelligenceInstallationRequestIDKey)
        synchronize()
    }
    
    // MARK:- Creation Date
    
    var phx_installationCreateDateString: String? {
        return objectForKey(intelligenceInstallationCreateDateKey) as? String
    }
    
    func phx_storeInstallationCreateDate(newDate: String?) {
        setObject(newDate, forKey: intelligenceInstallationCreateDateKey)
        synchronize()
    }
}
