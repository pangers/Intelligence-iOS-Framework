//
//  PhoenixInstallation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Manager used for Installation requests.
internal struct PhoenixInstallation {
    // MARK:- Keys
    static let InstallationId = "InstallationId"
    static let RequestId = "Id"
    static let ProjectId = "ProjectId"
    static let ApplicationId = "ApplicationId"
    static let CreateDate = "CreateDate"
    static let InstalledVersion = "InstalledVersion"
    static let DeviceTypeId = "DeviceTypeId"
    static let OperatingSystemVersion = "OperatingSystemVersion"
    static let ModelReference = "ModelReference"
    
    // MARK:- Storage
    /// Configuration to use for configuring the installation request.
    let configuration: Phoenix.Configuration
    /// Bundle of application used to get version and build number.
    let applicationVersion: PhoenixApplicationVersionProtocol
    /// User defaults to store response data for update installation request.
    let installationStorage: PhoenixInstallationStorageProtocol
    
    // MARK:- Parameters used in requests
    private let phoenixInstallationDefaultCreateID = "00000000-0000-0000-0000-000000000000"
    private var systemVersion: String { return UIDevice.currentDevice().systemVersion }
    private var modelReference: String { return UIDevice.currentDevice().model }
    private var deviceTypeId: String { return "Smartphone" }
    private var installationId: String { return installationStorage.phx_installationID ?? phoenixInstallationDefaultCreateID }
    private var installedVersion: String { return applicationVersion.phx_applicationVersionString ?? "" }
    private var applicationId: Int { return configuration.applicationID }
    private var projectId: Int { return configuration.projectID }
    private var requestId: Int? { return installationStorage.phx_installationRequestID }
    private var createDate: String? { return installationStorage.phx_installationCreateDateString }
    
    /// - Returns: True if valid to send an update with this object.
    var isValidToUpdate: Bool {
        return requestId != nil
    }
    
    /// - Returns: True if app is a fresh install or request has not made it to Phoenix yet.
    var isNewInstallation: Bool {
        return installationStorage.phx_isNewInstallation
    }
    
    /// - Returns: True if app is updated or request has not made it to Phoenix yet.
    var isUpdatedInstallation: Bool {
        return installationStorage.phx_isInstallationUpdated(applicationVersion.phx_applicationVersionString)
    }
    
    /// - Returns: JSON Dictionary representation used in Installation requests.
    func toJSON() -> JSONDictionary {
        var json: JSONDictionary = [
            PhoenixInstallation.ProjectId: projectId,
            PhoenixInstallation.ApplicationId: applicationId,
            PhoenixInstallation.InstallationId: installationId,
            PhoenixInstallation.InstalledVersion: installedVersion,
            PhoenixInstallation.DeviceTypeId: deviceTypeId,
            PhoenixInstallation.OperatingSystemVersion: systemVersion,
            PhoenixInstallation.ModelReference: modelReference]
        // Update Installation requires the Id of the previous Create Installation request.
        if requestId != nil {
            json[PhoenixInstallation.RequestId] = requestId!
        }
        // Currently, if we don't send the CreateDate the Phoenix backend will overwrite it with the ModifyDate.
        if createDate != nil {
            json[PhoenixInstallation.CreateDate] = createDate!
        }
        return json
    }
    
    /// Updates stored values with incoming JSON Dictionary.
    /// - Parameter json: JSON Dictionary response from Installation request.
    func updateWithJSON(json: JSONDictionary?) -> Bool {
        if let
            json = json,
            installation = json[PhoenixInstallation.InstallationId] as? String,
            id = json[PhoenixInstallation.RequestId] as? Int,
            installedVersion = json[PhoenixInstallation.InstalledVersion] as? String,
            createDate = json[PhoenixInstallation.CreateDate] as? String {
                installationStorage.phx_storeInstallationID(installation)
                installationStorage.phx_storeInstallationCreateDate(createDate)
                installationStorage.phx_storeInstallationRequestID(id)
                installationStorage.phx_storeApplicationVersion(installedVersion)
                return true
        }
        return false
    }
}