//
//  NSURLRequest.swift
//  IntelligenceSDK
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

internal enum IdentifierType : Int {
    case Email = 1
    case Msisdn = 2
    case iOSDeviceToken = 3
    case AndroidRegistrationID = 4
    case WindowsRegistrationID = 5
}


// MARK: - OAuth

internal extension NSURLRequest {
    private class func phx_HTTPHeaders(bearerOAuth: IntelligenceOAuthProtocol? = nil) -> [String: String] {
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
    
    /// Create a NSURLRequest for validate.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to validate a token.
    class func phx_URLRequestForValidate(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Authentication, configuration: configuration)!.phx_URLByAppendingOAuthValidatePath()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationFormUrlEncoded, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.GET.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    
    /// Create a NSURLRequest for refreshToken.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to refresh a token.
    class func phx_URLRequestForRefresh(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        assert(oauth.refreshToken != nil)
        let url = NSURL(module: .Authentication, configuration: configuration)!.phx_URLByAppendingOAuthTokenPath()
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
    
    /// Create a NSURLRequest for login.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to get a token.
    class func phx_URLRequestForLogin(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Authentication, configuration: configuration)!.phx_URLByAppendingOAuthTokenPath()
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
    
    /// Create a NSURLRequest for assignRole.
    /// - parameter roleId: The id of the role to assign.
    /// - parameter user: The user whose role we are assigning.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to assign a role to a given user.
    class func phx_URLRequestForUserRoleAssignment(roleId: Int, user: Intelligence.User, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let userid = String(user.userId).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let roleid = String(roleId).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let url = NSURL(module: .Identity, configuration: configuration)!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingAssignRole()
            .phx_URLByAppendingQueryString("userid=\(userid)&roleid=\(roleid)")
        let request = NSMutableURLRequest(URL: url)

        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    /// Create a NSURLRequest for revokeRole.
    /// - parameter roleId: The id of the role to revoke.
    /// - parameter user: The user whose role we are revoking.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to revoke a role from a given user.
    class func phx_URLRequestForUserRoleRevoke(roleId: Int, user: Intelligence.User, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let userid = String(user.userId).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let roleid = String(roleId).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let url = NSURL(module: .Identity, configuration: configuration)!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingRevokeRole()
            .phx_URLByAppendingQueryString("userid=\(userid)&roleid=\(roleid)")
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.DELETE.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    /// Create a NSURLRequest for createUser.
    /// - parameter user: The user we are creating.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to create the given user.
    class func phx_URLRequestForUserCreation(user: Intelligence.User, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Identity, configuration: configuration)!
            .phx_URLByAppendingCompanies(configuration.companyId)
            .phx_URLByAppendingUsers()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = [user.toJSON()].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
    /// Create a NSURLRequest for getUser.
    /// - parameter userId: The id for the user we are getting.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to get the user with the used credentials.
    class func phx_URLRequestForGetUser(userId: Int, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Identity, configuration: configuration)!
            .phx_URLByAppendingCompanies(configuration.companyId)
            .phx_URLByAppendingUsers(userId)
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.GET.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    /// Create a NSURLRequest for getUserMe.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to get the user with the used credentials.
    class func phx_URLRequestForUserMe(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Identity, configuration: configuration)!
            .phx_URLByAppendingProviders(configuration.providerId)
            .phx_URLByAppendingUsersMe()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.GET.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    /// Create a NSURLRequest for updateUser.
    /// - parameter user: The user we are updating.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to update the given user.
    class func phx_URLRequestForUserUpdate(user: Intelligence.User, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Identity, configuration: configuration)!
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
    
    /// Create a NSURLRequest for createIdentifier.
    /// - parameter tokenString: The identifier we will create.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to create an identifier.
    class func phx_URLRequestForIdentifierCreation(tokenString: String, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Identity, configuration: configuration)!
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
    
    /// Create a NSURLRequest for deleteIdentifier.
    /// - parameter tokenId: The id of the identifier we will delete.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to delete an identifier.
    class func phx_URLRequestForIdentifierDeletion(tokenId: Int, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Identity, configuration: configuration)!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingIdentifiers(tokenId)
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.DELETE.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    /// Create a NSURLRequest for deleteIdentifierOnBehalf.
    /// - parameter token: The identifier we will delete on behalf.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to delete an identifier on behalf.
    class func phx_URLRequestForIdentifierDeletionOnBehalf(token: String, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let applicationId = String(configuration.applicationID).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let identifierValue = token.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let identifierTypeId = String(IdentifierType.iOSDeviceToken.rawValue).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let url = NSURL(module: .Identity, configuration: configuration)!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingIdentifiers()
            .phx_URLByAppendingQueryString("applicationId=\(applicationId)&identifierValue=\(identifierValue)&identifierTypeId=\(identifierTypeId)")
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.DELETE.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    // MARK: Installation
    
    /// Create a NSURLRequest for createInstallation.
    /// - parameter installation: The installation we are creating.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - Returns: An NSURLRequest to create a given installation.
    class func phx_URLRequestForInstallationCreate(installation: Installation, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Identity, configuration: configuration)!
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingInstallations()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.addValue(HTTPHeaderApplicationJson, forHTTPHeaderField: HTTPHeaderContentTypeKey)
        
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = [installation.toJSON()].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
    /// Create a NSURLRequest for updateInstallation.
    /// - parameter installation: The installation we are updating.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to update a given installation.
    class func phx_URLRequestForInstallationUpdate(installation: Installation, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Identity, configuration: configuration)!
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
    
    /// Create a NSURLRequest for sendEvent.
    /// - parameter json: The details of the event we are sending.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - returns: An NSURLRequest to send an event.
    class func phx_URLRequestForAnalytics(json: JSONDictionaryArray, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network) -> NSURLRequest {
        let url = NSURL(module: .Analytics, configuration: configuration)!
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
    
    /// Create a NSURLRequest for downloadGeofences.
    /// - parameter oauth: The oauth values to use for this request.
    /// - parameter configuration: The configuration values to use for this request.
    /// - parameter network: The network the request will be queued on.
    /// - parameter query: The query to apply to the url.
    /// - returns: An NSURLRequest to download geofences.
    class func phx_URLRequestForDownloadGeofences(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, query:GeofenceQuery) -> NSURLRequest {
        let url = NSURL(module: .Location, configuration: configuration)!
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