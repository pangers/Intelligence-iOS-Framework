//
//  NSURL+Phoenix.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// This extension is intended to provide all the various path components required to compose urls for enpoints.
internal extension NSURL {
    
    /// - Returns: NSURL to obtain or refresh an OAuth token.
    func phx_URLByAppendingOAuthTokenPath() -> NSURL! {
        return URLByAppendingPathComponent("/token")
    }
    
    /// - Returns: NSURL for validation of current OAuth token.
    func phx_URLByAppendingOAuthValidatePath() -> NSURL! {
        return URLByAppendingPathComponent("/validate")
    }
    
    /// - Returns: NSURL with append identifiers path.
    func phx_URLByAppendingIdentifiers(tokenID: Int? = nil) -> NSURL! {
        if let tokenID = tokenID {
            return URLByAppendingPathComponent("/identifiers/\(tokenID)")
        }
        return URLByAppendingPathComponent("/identifiers")
    }
    
    /// - Returns: NSURL with append installations path.
    func phx_URLByAppendingInstallations() -> NSURL! {
        return URLByAppendingPathComponent("/installations")
    }
    
    /// - Returns: NSURL with append installations path.
    func phx_URLByAppendingEvents() -> NSURL! {
        return URLByAppendingPathComponent("/events")
    }
    
    /// - Returns: NSURL with append geofences path.
    func phx_URLByAppendingGeofences() -> NSURL! {
        return URLByAppendingPathComponent("/geofences")
    }
    
    /// - Returns: NSURL with append assign role path.
    func phx_URLByAppendingAssignRole() -> NSURL! {
        return URLByAppendingPathComponent("/assignrole")
    }
    
    /// - Returns: NSURL with appended providers path.
    func phx_URLByAppendingProviders(providerId: Int? = nil) -> NSURL! {
        if let providerId = providerId {
            return URLByAppendingPathComponent("/providers/\(providerId)")
        }
        return URLByAppendingPathComponent("/providers")
    }
    
    /// - Returns: NSURL with appended companies path.
    func phx_URLByAppendingCompanies(companyID: Int? = nil) -> NSURL! {
        if let companyID = companyID {
            return URLByAppendingPathComponent("/companies/\(companyID)")
        }
        return URLByAppendingPathComponent("/companies")
    }
    
    /// - Returns: NSURL with appended projects path.
    func phx_URLByAppendingProjects(projectID: Int? = nil) -> NSURL! {
        if let projectID = projectID {
            return URLByAppendingPathComponent("/projects/\(projectID)")
        }
        return URLByAppendingPathComponent("/projects")
    }
    
    /// - Returns: NSURL with appended users path.
    func phx_URLByAppendingUsers(userID: Int? = nil) -> NSURL! {
        if let userID = userID {
            return URLByAppendingPathComponent("/users/\(userID)")
        }
        return URLByAppendingPathComponent("/users")
    }
    
    /// - Returns: NSURL with appended '/users/me' path.
    func phx_URLByAppendingUsersMe() -> NSURL! {
        return URLByAppendingPathComponent("/users/me")
    }
    

    func phx_URLByAppendingQueryString(queryString:String) -> NSURL! {
        if queryString.characters.count == 0 {
            return self
        }
        let separator = (query?.isEmpty ?? true) ? "?" : "&"
        let URLString = "\(absoluteString)\(separator)\(queryString)"
        
        return NSURL(string: URLString)
    }

}
