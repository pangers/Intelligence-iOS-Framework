//
//  NSUserDefaultsInstallation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

protocol InstallationStorageProtocol {
    /// - Returns: Stored application version or nil.
    var int_applicationVersion: String? {get}
    /// Store current app version.
    func int_storeApplicationVersion(version: String?)
    /// - Returns: True if fresh installation.
    var int_isNewInstallation: Bool {get}
    /// - Returns: False if we cannot get stored app version or current app version.
    func int_isInstallationUpdated(applicationVersion: String?) -> Bool
    /// - Returns: Previous installation ID or zeros.
    var int_installationID: String? {get}
    /// Stores installation ID that was returned by the server.
    func int_storeInstallationID(newID: String?)
    /// - Returns: Previous request ID.
    var int_installationRequestID: Int? {get}
    /// Stores request ID that was returned by the server.
    func int_storeInstallationRequestID(newID: Int?)
    /// Intelligence currently requires us to send the creation date, otherwise it will update it to the current date.
    /// - Returns: Creation date of previous request.
    var int_installationCreateDateString: String? {get}
    /// Stores create date that was returned by the server.
    func int_storeInstallationCreateDate(newDate: String?)
}

private let intelligenceAppVersionKey = "IntelligenceAppVersion"
private let intelligenceInstallationIDKey = "InstallationID"
private let intelligenceInstallationCreateDateKey = "InstallationCreateDate"
private let intelligenceInstallationRequestIDKey = "InstallationRequestID"

extension UserDefaults: InstallationStorageProtocol {

    // MARK: - App Version
    var int_applicationVersion: String? {
        return object(forKey:
            intelligenceAppVersionKey) as? String
    }

    func int_storeApplicationVersion(version: String?) {
        set(version, forKey: intelligenceAppVersionKey)
        synchronize()
    }

    var int_isNewInstallation: Bool {
        return int_applicationVersion == nil
    }

    func int_isInstallationUpdated(applicationVersion: String?) -> Bool {
        guard let version = applicationVersion, let stored = int_applicationVersion else { return false }
        return version != stored // Assumption: any version change is considered an update
    }

    // MARK: - Installation ID

    var int_installationID: String? {
        return object(forKey: intelligenceInstallationIDKey) as? String
    }

    func int_storeInstallationID(newID: String?) {
        set(newID, forKey: intelligenceInstallationIDKey)
        synchronize()
    }

    // MARK: - Request ID

    var int_installationRequestID: Int? {
        return object(forKey: intelligenceInstallationRequestIDKey) as? Int
    }

    func int_storeInstallationRequestID(newID: Int?) {
        set(newID, forKey: intelligenceInstallationRequestIDKey)
        synchronize()
    }

    // MARK: - Creation Date

    var int_installationCreateDateString: String? {
        return object(forKey: intelligenceInstallationCreateDateKey) as? String
    }

    func int_storeInstallationCreateDate(newDate: String?) {
        set(newDate, forKey: intelligenceInstallationCreateDateKey)
        synchronize()
    }
}
