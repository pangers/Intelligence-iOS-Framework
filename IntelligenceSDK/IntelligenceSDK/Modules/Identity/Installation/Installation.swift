//
//  Installation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import UIKit

private enum DeviceType : Int {
    case smartphone = 1
    case tablet = 2
    case desktop = 3
    case smartTV = 4
    case wearable = 5
}

/// Manager used for Installation requests.
internal struct Installation {
    // MARK:- Keys
    static let InstallationId = "InstallationId"
    static let Id = "Id"
    static let ProjectId = "ProjectId"
    static let ApplicationId = "ApplicationId"
    static let CreateDate = "DateCreated"
    static let InstalledVersion = "InstalledVersion"
    static let DeviceTypeId = "DeviceTypeId"
    static let OperatingSystemVersion = "OperatingSystemVersion"
    static let UserId = "UserId"
    
    // MARK:- Storage
    /// Configuration to use for configuring the installation request.
    let configuration: Intelligence.Configuration
    /// Bundle of application used to get version and build number.
    let applicationVersion: IntelligenceApplicationVersionProtocol
    /// User defaults to store response data for update installation request.
    let installationStorage: InstallationStorageProtocol
    /// IntelligenceOAuthProvider to determine the user making the request.
    let oauthProvider: IntelligenceOAuthProvider
    
    // MARK:- Parameters used in requests
    private var systemVersion: String { return UIDevice.current.systemVersion }
    private var deviceTypeId: DeviceType { return .smartphone }
    private var installedVersion: String { return applicationVersion.int_applicationVersionString ?? "" }
    private var applicationId: Int { return configuration.applicationID }
    private var projectId: Int { return configuration.projectID }
    
    private var requestId: Int? { return installationStorage.int_installationRequestID }
    
    /// - Returns: True if valid to send an update with this object.
    var isValidToUpdate: Bool {
        return requestId != nil
    }
    
    /// - Returns: True if app is a fresh install or request has not made it to Intelligence yet.
    var isNewInstallation: Bool {
        return installationStorage.int_isNewInstallation
    }
    
    /// - Returns: True if app is updated or request has not made it to Intelligence yet.
    var isUpdatedInstallation: Bool {
        return installationStorage.int_isInstallationUpdated(applicationVersion: applicationVersion.int_applicationVersionString)
    }
    
    /// - Returns: JSON Dictionary representation used in Installation requests.
    func toJSON() -> JSONDictionary {
        var json: JSONDictionary = [
            Installation.InstalledVersion: installedVersion,
            Installation.DeviceTypeId: deviceTypeId.rawValue,
            Installation.OperatingSystemVersion: systemVersion]
        
        if requestId == nil {
            // Create Installation
            json[Installation.ProjectId] = projectId
            json[Installation.ApplicationId] = applicationId
        }
        else {
            // Update installation (with previous installions id)
            json[Installation.Id] = requestId!
        }
    
        return json
    }
    
    /// Updates stored values with incoming JSON Dictionary.
    /// - Parameter json: JSON Dictionary response from Installation request.
    func updateWithJSON(json: JSONDictionary?) -> Bool {
        if let
            json = json,
            let installation = json[Installation.InstallationId] as? String,
            let id = json[Installation.Id] as? Int,
            let installedVersion = json[Installation.InstalledVersion] as? String,
            let createDate = json[Installation.CreateDate] as? String {
                installationStorage.int_storeInstallationID(newID: installation)
                installationStorage.int_storeInstallationCreateDate(newDate: createDate)
                installationStorage.int_storeInstallationRequestID(newID: id)
                installationStorage.int_storeApplicationVersion(version: installedVersion)
                return true
        }
        return false
    }
}
