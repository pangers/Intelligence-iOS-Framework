//
//  NSURL+Phoenix.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

private let phoenixIdentityAPIVersion = "identity/v1"
private let phoenixLocationAPIVersion = "location/v1"
private let phoenixAnalyticsAPIVersion = "analytics/v1"

internal extension NSURL {
    
    func phx_URLByAppendingRootAnalyticsPath() -> NSURL! {
        return URLByAppendingPathComponent("/\(phoenixAnalyticsAPIVersion)")
    }
    
    func phx_URLByAppendingRootLocationPath() -> NSURL! {
        return URLByAppendingPathComponent("/\(phoenixLocationAPIVersion)")
    }
    
    func phx_URLByAppendingRootIdentityPath() -> NSURL! {
        return URLByAppendingPathComponent("/\(phoenixIdentityAPIVersion)")
    }
    
    /// - Returns: NSURL to obtain or refresh an OAuth token.
    func phx_URLByAppendingOAuthTokenPath() -> NSURL! {
        return URLByAppendingPathComponent("\(phoenixIdentityAPIVersion)/oauth/token")
    }
    
    /// - Returns: NSURL for validation of current OAuth token.
    func phx_URLByAppendingOAuthValidatePath() -> NSURL! {
        return URLByAppendingPathComponent("\(phoenixIdentityAPIVersion)/oauth/validate")
    }
    
    /// - Returns: NSURL with appended applications path.
    func phx_URLByAppendingApplications(applicationID: Int? = nil) -> NSURL! {
        if let applicationID = applicationID {
            return URLByAppendingPathComponent("/applications/\(applicationID)")
        }
        return URLByAppendingPathComponent("/applications")
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
    
    /// - Returns: NSURL with append geofences path.
    func phx_URLByAppendingRoles() -> NSURL! {
        return URLByAppendingPathComponent("/roles")
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
