//
//  NSURL+Intelligence.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

enum Module : String {
    case NoModule = ""
    case Authentication = "authentication"
    case Identity = "identity"
    case Analytics = "analytics"
    case Location = "location"
}

/// This extension is used to map the enum to the url, not for any other purpose
private extension Intelligence.Environment {
    private func urlComponent() -> String? {
        let urlComponent: String
        
        switch (self) {
            case .Local:
                urlComponent = "local"
            case .Development:
                urlComponent = "dev"
            case .Integration:
                urlComponent = "int"
            case .UAT:
                urlComponent = "uat"
            case .Staging:
                urlComponent = "staging"
            case .Production:
                urlComponent = ""
        }
        
        if urlComponent.characters.count > 0 {
            return "-" + urlComponent
        }
        else {
            return urlComponent
        }
    }
}

/// This extension is used to map the enum to the url, not for any other purpose
private extension Intelligence.Region {
    private func urlComponent() -> String? {
        switch (self) {
            case .UnitedStates:
                return ".com"
            case .Australia:
                return ".com.au"
            case .Europe:
                return ".eu"
            case .Singapore:
                return ".com.sg"
        }
    }
}

/// This extension is intended to provide all the various path components required to compose urls for enpoints.
internal extension NSURL {
    convenience init?(module: Module, configuration: Intelligence.Configuration) {
        self.init(module: module, environment: configuration.environment, region: configuration.region)
    }
    
    convenience init?(module: Module, environment: Intelligence.Environment?, region: Intelligence.Region?) {
        let moduleInURL = module.rawValue
        
        guard let environmentInURL = environment?.urlComponent() else {
            return nil
        }
        
        guard let regionInURL = region?.urlComponent() else {
            return nil
        }
        
        
        let url = String(format: "https://\(moduleInURL)\(environmentInURL).phoenixplatform\(regionInURL)/v2",
            arguments: [moduleInURL, environmentInURL, regionInURL])
        
        self.init(string: url)
    }
    
    /// - Returns: NSURL to obtain or refresh an OAuth token.
    func int_URLByAppendingOAuthTokenPath() -> NSURL! {
        return URLByAppendingPathComponent("/token")
    }
    
    /// - Returns: NSURL for validation of current OAuth token.
    func int_URLByAppendingOAuthValidatePath() -> NSURL! {
        return URLByAppendingPathComponent("/validate")
    }
    
    /// - Returns: NSURL with appended identifiers path.
    func int_URLByAppendingIdentifiers(tokenID: Int? = nil) -> NSURL! {
        if let tokenID = tokenID {
            return URLByAppendingPathComponent("/identifiers/\(tokenID)")
        }
        return URLByAppendingPathComponent("/identifiers")
    }
    
    /// - Returns: NSURL with appended installations path.
    func int_URLByAppendingInstallations() -> NSURL! {
        return URLByAppendingPathComponent("/installations")
    }
    
    /// - Returns: NSURL with appended installations path.
    func int_URLByAppendingEvents() -> NSURL! {
        return URLByAppendingPathComponent("/events")
    }
    
    /// - Returns: NSURL with appended geofences path.
    func int_URLByAppendingGeofences() -> NSURL! {
        return URLByAppendingPathComponent("/geofences")
    }
    
    /// - Returns: NSURL with appended assign role path.
    func int_URLByAppendingAssignRole() -> NSURL! {
        return URLByAppendingPathComponent("/assignrole")
    }
    
    /// - Returns: NSURL with appended revoke role path.
    func int_URLByAppendingRevokeRole() -> NSURL! {
        return URLByAppendingPathComponent("/revokerole")
    }
    
    /// - Returns: NSURL with appended providers path.
    func int_URLByAppendingProviders(providerId: Int? = nil) -> NSURL! {
        if let providerId = providerId {
            return URLByAppendingPathComponent("/providers/\(providerId)")
        }
        return URLByAppendingPathComponent("/providers")
    }
    
    /// - Returns: NSURL with appended companies path.
    func int_URLByAppendingCompanies(companyID: Int? = nil) -> NSURL! {
        if let companyID = companyID {
            return URLByAppendingPathComponent("/companies/\(companyID)")
        }
        return URLByAppendingPathComponent("/companies")
    }
    
    /// - Returns: NSURL with appended projects path.
    func int_URLByAppendingProjects(projectID: Int? = nil) -> NSURL! {
        if let projectID = projectID {
            return URLByAppendingPathComponent("/projects/\(projectID)")
        }
        return URLByAppendingPathComponent("/projects")
    }
    
    /// - Returns: NSURL with appended users path.
    func int_URLByAppendingUsers(userID: Int? = nil) -> NSURL! {
        if let userID = userID {
            return URLByAppendingPathComponent("/users/\(userID)")
        }
        return URLByAppendingPathComponent("/users")
    }
    
    /// - Returns: NSURL with appended '/users/me' path.
    func int_URLByAppendingUsersMe() -> NSURL! {
        return URLByAppendingPathComponent("/users/me")
    }
    

    func int_URLByAppendingQueryString(queryString:String) -> NSURL! {
        if queryString.characters.count == 0 {
            return self
        }
        let separator = (query?.isEmpty ?? true) ? "?" : "&"
        let URLString = "\(absoluteString!)\(separator)\(queryString)"
        
        return NSURL(string: URLString)
    }

}
