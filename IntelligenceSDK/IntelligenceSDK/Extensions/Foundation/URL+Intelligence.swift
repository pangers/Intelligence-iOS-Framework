//
//  NSURL+Intelligence.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

enum Module : String {
    case noModule = ""
    case authentication = "authentication"
    case identity = "identity"
    case analytics = "analytics"
    case location = "location"
}

/// This extension is used to map the enum to the url, not for any other purpose
fileprivate extension Intelligence.Environment {
    fileprivate func urlComponent() -> String? {
        let urlComponent: String
        
        switch (self) {
            case .local:
                urlComponent = "local"
            case .development:
                urlComponent = "dev"
            case .integration:
                urlComponent = "int"
            case .uat:
                urlComponent = "uat"
            case .staging:
                urlComponent = "staging"
            case .production:
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
fileprivate extension Intelligence.Region {
    fileprivate func urlComponent() -> String? {
        switch (self) {
            case .unitedStates:
                return ".com"
            case .australia:
                return ".com.au"
            case .europe:
                return ".eu"
            case .singapore:
                return ".com.sg"
        }
    }
}

/// This extension is intended to provide all the various path components required to compose urls for enpoints.
internal extension URL {
    init?(module: Module, configuration: Intelligence.Configuration) {
        self.init(module: module, environment: configuration.environment, region: configuration.region)
    }
    
    init?(module: Module, environment: Intelligence.Environment?, region: Intelligence.Region?) {
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
    func int_URLByAppendingOAuthTokenPath() -> URL {
        return appendingPathComponent("/token")
    }
    
    /// - Returns: NSURL for validation of current OAuth token.
    func int_URLByAppendingOAuthValidatePath() -> URL {
        return appendingPathComponent("/validate")
    }
    
    /// - Returns: NSURL with appended identifiers path.
    func int_URLByAppendingIdentifiers(tokenID: Int? = nil) -> URL {
        if let tokenID = tokenID {
            return appendingPathComponent("/identifiers/\(tokenID)")
        }
        return appendingPathComponent("/identifiers")
    }
    
    /// - Returns: NSURL with appended installations path.
    func int_URLByAppendingInstallations() -> URL {
        return appendingPathComponent("/installations")
    }
    
    /// - Returns: NSURL with appended installations path.
    func int_URLByAppendingEvents() -> URL {
        return appendingPathComponent("/events")
    }
    
    /// - Returns: NSURL with appended geofences path.
    func int_URLByAppendingGeofences() -> URL {
        return appendingPathComponent("/geofences")
    }
    
    /// - Returns: NSURL with appended assign role path.
    func int_URLByAppendingAssignRole() -> URL {
        return appendingPathComponent("/assignrole")
    }
    
    /// - Returns: NSURL with appended revoke role path.
    func int_URLByAppendingRevokeRole() -> URL {
        return appendingPathComponent("/revokerole")
    }
    
    /// - Returns: NSURL with appended providers path.
    func int_URLByAppendingProviders(providerId: Int? = nil) -> URL {
        if let providerId = providerId {
            return appendingPathComponent("/providers/\(providerId)")
        }
        return appendingPathComponent("/providers")
    }
    
    /// - Returns: NSURL with appended companies path.
    func int_URLByAppendingCompanies(companyID: Int? = nil) -> URL {
        if let companyID = companyID {
            return appendingPathComponent("/companies/\(companyID)")
        }
        return appendingPathComponent("/companies")
    }
    
    /// - Returns: NSURL with appended projects path.
    func int_URLByAppendingProjects(projectID: Int? = nil) -> URL {
        if let projectID = projectID {
            return appendingPathComponent("/projects/\(projectID)")
        }
        return appendingPathComponent("/projects")
    }
    
    /// - Returns: NSURL with appended users path.
    func int_URLByAppendingUsers(userID: Int? = nil) -> URL {
        if let userID = userID {
            return appendingPathComponent("/users/\(userID)")
        }
        return appendingPathComponent("/users")
    }
    
    /// - Returns: NSURL with appended '/users/me' path.
    func int_URLByAppendingUsersMe() -> URL {
        return appendingPathComponent("/users/me")
    }
    

    func int_URLByAppendingQueryString(queryString:String) -> URL? {
        if queryString.characters.count == 0 {
            return self
        }
        let separator = (query?.isEmpty ?? true) ? "?" : "&"
        let URLString = "\(absoluteString)\(separator)\(queryString)"
        
        return URL(string: URLString)
    }

}
