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
        return NSURL(string: "/\(phoenixAnalyticsAPIVersion)", relativeToURL: self)
    }
    
    func phx_URLByAppendingRootLocationPath() -> NSURL! {
        return NSURL(string: "/\(phoenixLocationAPIVersion)", relativeToURL: self)
    }
    
    func phx_URLByAppendingRootIdentityPath() -> NSURL! {
        return NSURL(string: "/\(phoenixIdentityAPIVersion)", relativeToURL: self)
    }
    
    /// - Returns: NSURL to obtain or refresh an OAuth token.
    func phx_URLByAppendingOAuthTokenPath() -> NSURL! {
        return NSURL(string: "\(phoenixIdentityAPIVersion)/oauth/token", relativeToURL: self)
    }
    
    /// - Returns: NSURL for validation of current OAuth token.
    func phx_URLByAppendingOAuthValidatePath() -> NSURL! {
        return NSURL(string: "\(phoenixIdentityAPIVersion)/oauth/validate", relativeToURL: self)
    }
    
    /// - Returns: NSURL with appended applications path.
    func phx_URLByAppendingApplications(applicationID: Int? = nil) -> NSURL! {
        if let applicationID = applicationID {
            return NSURL(string: "/applications/\(applicationID)", relativeToURL: self)
        } else {
            return NSURL(string: "/applications", relativeToURL: self)
        }
    }
    
    /// - Returns: NSURL with append installations path.
    func phx_URLByAppendingInstallations() -> NSURL! {
        return NSURL(string: "/installations", relativeToURL: self)
    }
    
    /// - Returns: NSURL with append installations path.
    func phx_URLByAppendingEvents() -> NSURL! {
        return NSURL(string: "/events", relativeToURL: self)
    }
    
    /// - Returns: NSURL with append geofences path.
    func phx_URLByAppendingGeofences() -> NSURL! {
        return NSURL(string: "/geofences", relativeToURL: self)
    }
    
    /// - Returns: NSURL with appended projects path.
    func phx_URLByAppendingProjects(projectID: Int? = nil) -> NSURL! {
        if let projectID = projectID {
            return NSURL(string: "/projects/\(projectID)", relativeToURL: self)
        } else {
            return NSURL(string: "/projects", relativeToURL: self)
        }
    }
    
    /// - Returns: NSURL with appended users path.
    func phx_URLByAppendingUsers(userID: Int? = nil) -> NSURL! {
        if let userID = userID {
            return NSURL(string: "/users/\(userID)", relativeToURL: self)
        } else {
            return NSURL(string: "/users", relativeToURL: self)
        }
    }
    
    /// - Returns: NSURL with appended '/users/me' path.
    func phx_URLByAppendingUsersMe() -> NSURL! {
        return NSURL(string: "/users/me", relativeToURL: self)
    }
}
