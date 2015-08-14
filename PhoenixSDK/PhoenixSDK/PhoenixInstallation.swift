//
//  PhoenixInstallation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

extension Phoenix {
    /// Manager used for Installation requests.
    internal struct Installation {
        // MARK:- Keys
        private static let InstallationId = "InstallationId"
        private static let RequestId = "Id"
        private static let CreateDate = "CreateDate"
        
        // MARK:- Storage
        /// Configuration to use for configuring the installation request.
        let configuration: Configuration
        /// Bundle of application used to get version and build number.
        let bundle: NSBundle
        /// User defaults to store response data for update installation request.
        let userDefaults: NSUserDefaults
        
        // MARK:- Parameters used in requests
        private var systemVersion: String { return UIDevice.currentDevice().systemVersion }
        private var modelReference: String { return UIDevice.currentDevice().model }
        private var deviceTypeId: String { return "Smartphone" }
        private var installationId: String { return userDefaults.phoenix_installationID }
        private var installedVersion: String { return userDefaults.phoenix_storedApplicationVersion ?? bundle.phoenix_applicationVersionString ?? "" }
        private var applicationId: Int { return configuration.applicationID }
        private var projectId: Int { return configuration.projectID }
        private var requestId: Int? { return userDefaults.phoenix_requestID }
        private var createDate: String? { return userDefaults.phoenix_installationCreateDataString }
        
        var isNewInstallation: Bool {
            return userDefaults.phoenix_isNewInstallation
        }
        
        var isUpdatedInstallation: Bool {
            return userDefaults.phoenix_isInstallationUpdated(bundle.phoenix_applicationVersionString)
        }
        
        /// - Returns: JSON Dictionary representation used in Installation requests.
        func toJSON() -> JSONDictionary {
            var json: JSONDictionary = [
                "ProjectId": projectId,
                "ApplicationId": applicationId,
                Installation.InstallationId: installationId,
                "InstalledVersion": installedVersion,
                "DeviceTypeId": deviceTypeId,
                "OperatingSystemVersion": systemVersion,
                "ModelReference": modelReference]
            // Update Installation requires the Id of the previous Create Installation request.
            if requestId != nil {
                json[Installation.RequestId] = requestId!
            }
            // Currently, if we don't send the CreateDate the Phoenix backend will overwrite it with the ModifyDate.
            if createDate != nil {
                json[Installation.CreateDate] = createDate!
            }
            return json
        }
        
        /// Updates stored values with incoming JSON Dictionary.
        /// - Parameter json: JSON Dictionary response from Installation request.
        func updateWithJSON(json: JSONDictionary) -> Bool {
            if let installation = json[Installation.InstallationId] as? String,
                id = json[Installation.RequestId] as? Int,
                createDate = json[Installation.CreateDate] as? String {
                    userDefaults.phoenix_storeInstallationID(installation)
                    userDefaults.phoenix_storeInstallationCreateDate(createDate)
                    userDefaults.phoenix_storeInstallationRequestID(id)
                    userDefaults.phoenix_storeApplicationVersion(bundle.phoenix_applicationVersionString)
                    return true
            }
            return false
        }
    }
}