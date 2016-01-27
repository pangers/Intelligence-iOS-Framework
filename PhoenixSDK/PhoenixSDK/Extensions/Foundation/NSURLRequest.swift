//
//  NSURLRequest.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 28/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

private let HTTPHeaderAcceptKey = "Accept"
private let HTTPHeaderAuthorizationKey = "Authorization"
private let HTTPHeaderContentTypeKey = "Content-Type"
private let HTTPHeaderApplicationJson = "application/json"
private let HTTPHeaderApplicationFormUrlEncoded = "application/x-www-form-urlencoded"

private let HTTPBodyClientIDKey = "client_id"
private let HTTPBodyClientSecretKey = "client_secret"
private let HTTPBodyRefreshTokenKey = "refresh_token"
private let HTTPBodyUsernameKey = "username"
private let HTTPBodyPasswordKey = "password"

private let HTTPBodyGrantTypeKey = "grant_type"
private let HTTPBodyGrantTypeClientCredentials = "client_credentials"
private let HTTPBodyGrantTypePassword = "password"
private let HTTPBodyGrantTypeRefreshToken = "refresh_token"

private enum IdentifierType : Int {
    case Email = 1
    case Msisdn = 2
    case iOSDeviceToken = 3
    case AndroidRegistrationID = 4
    case WindowsRegistrationID = 5
}


// MARK: - OAuth

internal extension NSURLRequest {
    private class func phx_HTTPHeaders(bearerOAuth: PhoenixOAuthProtocol? = nil) -> [String: String] {
        var headers = [String: String]()
        headers[HTTPHeaderAcceptKey] = HTTPHeaderApplicationJson
        if (bearerOAuth != nil && bearerOAuth?.accessToken != nil) {
            headers[HTTPHeaderAuthorizationKey] = "Bearer \(bearerOAuth!.accessToken!)"
        }
        return headers
    }
    
    private class func phx_HTTPBodyData(body: [String: String]) -> NSData {
        return body.map({ "\($0.0)=\($0.1)" }).joinWithSeparator("&").dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    class func phx_URLRequestForValidate(oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.authenticationBaseURL()!.phx_URLByAppendingOAuthValidatePath()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationFormUrlEncoded, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.GET.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    class func phx_URLRequestForRefresh(oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        assert(oauth.refreshToken != nil)
        let url = configuration.authenticationBaseURL()!.phx_URLByAppendingOAuthTokenPath()
        let request = NSMutableURLRequest(URL: url)
        
        var body = [String: String]()
        body[HTTPBodyClientIDKey] = configuration.clientID
        body[HTTPBodyClientSecretKey] = configuration.clientSecret
        body[HTTPBodyGrantTypeKey] = HTTPBodyGrantTypeRefreshToken
        body[HTTPBodyRefreshTokenKey] = oauth.refreshToken
        
        request.allHTTPHeaderFields = phx_HTTPHeaders()
        request.addValue(HTTPHeaderApplicationFormUrlEncoded, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = phx_HTTPBodyData(body)
        return request.copy() as! NSURLRequest
    }
    
    class func phx_URLRequestForLogin(oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.authenticationBaseURL()!.phx_URLByAppendingOAuthTokenPath()
        let request = NSMutableURLRequest(URL: url)
        
        var body = [String: String]()
        body[HTTPBodyClientIDKey] = configuration.clientID
        body[HTTPBodyClientSecretKey] = configuration.clientSecret
        if oauth.tokenType == .Application {
            body[HTTPBodyGrantTypeKey] = HTTPBodyGrantTypeClientCredentials
        } else {
            body[HTTPBodyGrantTypeKey] = HTTPBodyGrantTypePassword
            body[HTTPBodyUsernameKey] = oauth.username!
            body[HTTPBodyPasswordKey] = oauth.password!
        }
        
        request.allHTTPHeaderFields = phx_HTTPHeaders()
        request.addValue(HTTPHeaderApplicationFormUrlEncoded, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = phx_HTTPBodyData(body)
        return request.copy() as! NSURLRequest
    }
}



// MARK:- Identity Module

internal extension NSURLRequest {
    
    /// - returns: An NSURLRequest to assign a role to a given user.
    class func phx_URLRequestForUserRoleAssignment(user: Phoenix.User, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.identityBaseURL()!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingAssignRole()
            .phx_URLByAppendingQueryString("userid=\(user.userId)&roleid=\(configuration.sdkUserRole)")
        let request = NSMutableURLRequest(URL: url)

        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    /// - returns: An NSURLRequest to create the given user.
    class func phx_URLRequestForUserCreation(user: Phoenix.User, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.identityBaseURL()!
            .phx_URLByAppendingCompanies(configuration.companyId)
            .phx_URLByAppendingUsers()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = [user.toJSON()].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
    /// - returns: An NSURLRequest to get the user with the used credentials.
    class func phx_URLRequestForUserMe(oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.identityBaseURL()!
            .phx_URLByAppendingProviders(configuration.providerId)
            .phx_URLByAppendingUsersMe()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.GET.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    /// - returns: An NSURLRequest to update the given user.
    class func phx_URLRequestForUserUpdate(user: Phoenix.User, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.identityBaseURL()!
            .phx_URLByAppendingCompanies(configuration.companyId)
            .phx_URLByAppendingUsers()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.PUT.rawValue
        request.HTTPBody = [user.toJSON()].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
    // MARK: Identifiers
    
    class func phx_URLRequestForIdentifierCreation(tokenString: String, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.identityBaseURL()!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingIdentifiers()
        let request = NSMutableURLRequest(URL: url)
        
        var json : [String : AnyObject] = ["ApplicationId": configuration.applicationID,
            "IdentifierTypeId": IdentifierType.iOSDeviceToken.rawValue,
            "IsConfirmed": true,
            "Value": tokenString]
        
        if let userId = network.oauthProvider.loggedInUserOAuth.userId {
            json["UserId"] = userId
        }
        else if let userId = network.oauthProvider.sdkUserOAuth.userId {
            json["UserId"] = userId
        }
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = [json].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
    class func phx_URLRequestForIdentifierDeletion(tokenId: Int, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.identityBaseURL()!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingIdentifiers(tokenId)
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.DELETE.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    // MARK: Installation
    
    /// - Returns: An NSURLRequest to create a given installation.
    class func phx_URLRequestForInstallationCreate(installation: Installation, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.identityBaseURL()!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingInstallations()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = [installation.toJSON()].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    

    /// - returns: An NSURLRequest to update a given installation.
    class func phx_URLRequestForInstallationUpdate(installation: Installation, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.identityBaseURL()!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingInstallations()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.PUT.rawValue
        request.HTTPBody = [installation.toJSON()].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
}



// MARK:- Analytics Module
internal extension NSURLRequest {
    
    class func phx_URLRequestForAnalytics(json: JSONDictionaryArray, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) -> NSURLRequest {
        let url = configuration.analyticsBaseURL()!
            .phx_URLByAppendingRootAnalyticsPath()
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingEvents()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = json.phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
}



// MARK:- Location Module

internal extension NSURLRequest {
    
    /// - returns: An NSURLRequest to download geofences.
    class func phx_URLRequestForDownloadGeofences(oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, query:GeofenceQuery) -> NSURLRequest {
        let url = configuration.locationBaseURL()!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingGeofences()
            .phx_URLByAppendingQueryString(query.urlQueryString())
        let request = NSMutableURLRequest(URL: url)

        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.GET.rawValue
        // TODO: Add filtering
        
        return request.copy() as! NSURLRequest
    }
}