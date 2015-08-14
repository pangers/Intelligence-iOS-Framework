//
//  NSUserDefaultsInstallation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal protocol PhoenixInstallationStorageProtocol {
    /// - Returns: Stored application version or nil.
    var phoenix_storedApplicationVersion: String? {get}
    /// Store current app version.
    func phoenix_storeApplicationVersion(version: String?)
    /// - Returns: True if fresh installation.
    var phoenix_isNewInstallation: Bool {get}
    /// - Returns: False if we cannot get stored app version or current app version.
    func phoenix_isInstallationUpdated(applicationVersion: String?) -> Bool
    /// - Returns: Previous installation ID or zeros.
    var phoenix_installationID: String {get}
    /// Stores installation ID that was returned by the server.
    func phoenix_storeInstallationID(newID: String?)
    /// - Returns: Previous request ID.
    var phoenix_installationRequestID: Int? {get}
    /// Stores request ID that was returned by the server.
    func phoenix_storeInstallationRequestID(newID: Int?)
    /// Phoenix currently requires us to send the creation date, otherwise it will update it to the current date.
    /// - Returns: Creation date of previous request.
    var phoenix_installationCreateDateString: String? {get}
    /// Stores create date that was returned by the server.
    func phoenix_storeInstallationCreateDate(newDate: String?)
}

private let phoenixInstallationDefaultCreateID = "00000000-0000-0000-0000-000000000000"
private let phoenixAppVersionKey = "PhoenixAppVersion"
private let phoenixInstallationIDKey = "PhoenixInstallationID"
private let phoenixInstallationCreateDateKey = "PhoenixInstallationCreateDate"
private let phoenixInstallationRequestIDKey = "PhoenixInstallationRequestID"

extension NSUserDefaults: PhoenixInstallationStorageProtocol {
    
    // MARK:- App Version
    var phoenix_storedApplicationVersion: String? {
        return objectForKey(phoenixAppVersionKey) as? String
    }
    
    func phoenix_storeApplicationVersion(version: String?) {
        setObject(version, forKey: phoenixAppVersionKey)
        synchronize()
    }
    
    var phoenix_isNewInstallation: Bool {
        return phoenix_storedApplicationVersion == nil
    }
    
    func phoenix_isInstallationUpdated(applicationVersion: String?) -> Bool {
        guard let version = applicationVersion, stored = phoenix_storedApplicationVersion else { return false }
        return version != stored // Assumption: any version change is considered an update
    }
    
    // MARK:- Installation ID
    
    var phoenix_installationID: String {
        return objectForKey(phoenixInstallationIDKey) as? String ?? phoenixInstallationDefaultCreateID
    }
    
    func phoenix_storeInstallationID(newID: String?) {
        setObject(newID, forKey: phoenixInstallationIDKey)
        synchronize()
    }
    
    // MARK:- Request ID
    
    var phoenix_installationRequestID: Int? {
        return objectForKey(phoenixInstallationRequestIDKey) as? Int
    }
    
    func phoenix_storeInstallationRequestID(newID: Int?) {
        setObject(newID, forKey: phoenixInstallationRequestIDKey)
        synchronize()
    }
    
    // MARK:- Creation Date
    
    var phoenix_installationCreateDateString: String? {
        return objectForKey(phoenixInstallationCreateDateKey) as? String
    }
    
    func phoenix_storeInstallationCreateDate(newDate: String?) {
        setObject(newDate, forKey: phoenixInstallationCreateDateKey)
        synchronize()
    }
}
