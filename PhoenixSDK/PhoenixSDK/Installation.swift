//
//  Installation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

private enum ApplicationType : Int {
    case AppleiOS = 1
    case GoogleAndroid = 2
    case HTML5 = 3
    case DotNet = 4
}

private enum DeviceType : Int {
    case Smartphone = 1
    case Tablet = 2
    case Desktop = 3
    case SmartTV = 4
    case Wearable = 5
}

/// Manager used for Installation requests.
internal struct Installation {
    // MARK:- Keys
    static let InstallationId = "InstallationId"
    static let Id = "Id"
    static let ProjectId = "ProjectId"
    static let ApplicationId = "ApplicationId"
    static let CreateDate = "DateCreated"
    static let ApplicationTypeId = "ApplicationTypeId"
    static let InstalledVersion = "InstalledVersion"
    static let DeviceTypeId = "DeviceTypeId"
    static let OperatingSystemVersion = "OperatingSystemVersion"
    static let UserId = "UserId"
    
    // MARK:- Storage
    /// Configuration to use for configuring the installation request.
    let configuration: Phoenix.Configuration
    /// Bundle of application used to get version and build number.
    let applicationVersion: PhoenixApplicationVersionProtocol
    /// User defaults to store response data for update installation request.
    let installationStorage: InstallationStorageProtocol
    /// PhoenixOAuthProvider to determine the user making the request.
    let oauthProvider: PhoenixOAuthProvider
    
    // MARK:- Parameters used in requests
    private var systemVersion: String { return UIDevice.currentDevice().systemVersion }
    private var deviceTypeId: DeviceType { return .Smartphone }
    private var installedVersion: String { return applicationVersion.phx_applicationVersionString ?? "" }
    private var applicationId: Int { return configuration.applicationID }
    private var applicationTypeId: ApplicationType { return .AppleiOS }
    private var projectId: Int { return configuration.projectID }
    private var userId: Int? { return oauthProvider.sdkUserOAuth.userId }
    private var requestId: Int? { return installationStorage.phx_installationRequestID }
    
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
            Installation.ProjectId: projectId,
            Installation.ApplicationId: applicationId,
            Installation.ApplicationTypeId: applicationTypeId.rawValue,
            Installation.InstalledVersion: installedVersion,
            Installation.DeviceTypeId: deviceTypeId.rawValue,
            Installation.OperatingSystemVersion: systemVersion]
        
        // Pass the userId if it is valid
        if userId != nil {
            json[Installation.UserId] = userId!
        }
        
        // Update Installation requires the Id of the previous Create Installation request.
        if requestId != nil {
            json[Installation.Id] = requestId!
        }
        return json
    }
    
    /// Updates stored values with incoming JSON Dictionary.
    /// - Parameter json: JSON Dictionary response from Installation request.
    func updateWithJSON(json: JSONDictionary?) -> Bool {
        if let
            json = json,
            installation = json[Installation.InstallationId] as? String,
            id = json[Installation.Id] as? Int,
            installedVersion = json[Installation.InstalledVersion] as? String,
            createDate = json[Installation.CreateDate] as? String {
                installationStorage.phx_storeInstallationID(installation)
                installationStorage.phx_storeInstallationCreateDate(createDate)
                installationStorage.phx_storeInstallationRequestID(id)
                installationStorage.phx_storeApplicationVersion(installedVersion)
                return true
        }
        return false
    }
}