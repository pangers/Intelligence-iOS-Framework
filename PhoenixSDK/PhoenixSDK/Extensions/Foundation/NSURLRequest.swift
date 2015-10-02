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

// MARK: - OAuth

internal extension NSURLRequest {
    private class func phx_HTTPHeaders(bearerOAuth: PhoenixOAuth? = nil) -> [String: String] {
        var headers = [String: String]()
        headers[HTTPHeaderContentTypeKey] = HTTPHeaderApplicationFormUrlEncoded
        headers[HTTPHeaderAcceptKey] = HTTPHeaderApplicationJson
        if (bearerOAuth != nil && bearerOAuth?.accessToken != nil) {
            headers[HTTPHeaderAuthorizationKey] = "Bearer \(bearerOAuth!.accessToken!)"
        }
        return headers
    }
    
    private class func phx_HTTPBodyData(body: [String: String]) -> NSData {
        return body.map({ "\($0.0)=\($0.1)" }).joinWithSeparator("&").dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    class func phx_URLRequestForValidate(oauth: PhoenixOAuth, phoenix: Phoenix) -> NSURLRequest {
        let configuration = phoenix.internalConfiguration
        let url = configuration.baseURL!.phx_URLByAppendingOAuthValidatePath()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.HTTPMethod = HTTPRequestMethod.GET.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    class func phx_URLRequestForRefresh(oauth: PhoenixOAuth, phoenix: Phoenix) -> NSURLRequest {
        assert(oauth.refreshToken != nil)
        let configuration = phoenix.internalConfiguration
        let url = configuration.baseURL!.phx_URLByAppendingOAuthTokenPath()
        let request = NSMutableURLRequest(URL: url)
        
        var body = [String: String]()
        body[HTTPBodyClientIDKey] = configuration.clientID
        body[HTTPBodyClientSecretKey] = configuration.clientSecret
        body[HTTPBodyGrantTypeKey] = HTTPBodyGrantTypeRefreshToken
        body[HTTPBodyRefreshTokenKey] = oauth.refreshToken
        
        request.allHTTPHeaderFields = phx_HTTPHeaders()
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = phx_HTTPBodyData(body)
        return request.copy() as! NSURLRequest
    }
    
    class func phx_URLRequestForLogin(oauth: PhoenixOAuth, phoenix: Phoenix) -> NSURLRequest {
        let configuration = phoenix.internalConfiguration
        let url = configuration.baseURL!.phx_URLByAppendingOAuthTokenPath()
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
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = phx_HTTPBodyData(body)
        return request.copy() as! NSURLRequest
    }
}



// MARK:- Identity Module

internal extension NSURLRequest {
    
    /// - returns: An NSURLRequest to create the given user.
    class func phx_URLRequestForUserCreation(user: Phoenix.User, phoenix: Phoenix) -> NSURLRequest {
        let configuration = phoenix.internalConfiguration
        let oauth = PhoenixOAuth(tokenType: .Application)
        let url = configuration.baseURL!
            .phx_URLByAppendingRootIdentityPath()
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingUsers()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = [user.toJSON()].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
    /// - returns: An NSURLRequest to get the user with the used credentials.
    class func phx_URLRequestForUserMe(oauth: PhoenixOAuth, phoenix: Phoenix) -> NSURLRequest {
        assert(oauth.tokenType != .Application, "Only SDK/LoggedIn Users can call this request.")
        
        let url = phoenix.internalConfiguration.baseURL!
            .phx_URLByAppendingRootIdentityPath()
            .phx_URLByAppendingUsersMe()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.HTTPMethod = HTTPRequestMethod.GET.rawValue
        
        return request.copy() as! NSURLRequest
    }
    
    /// - returns: An NSURLRequest to update the given user.
    class func phx_URLRequestForUserUpdate(user: Phoenix.User, oauth: PhoenixOAuth, phoenix: Phoenix) -> NSURLRequest {
        assert(oauth.tokenType != .Application, "Only SDK/LoggedIn Users can call this request.")
        
        let configuration = phoenix.internalConfiguration
        let url = configuration.baseURL!
            .phx_URLByAppendingRootIdentityPath()
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingUsers(user.userId)
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.HTTPMethod = HTTPRequestMethod.PUT.rawValue
        request.HTTPBody = [user.toJSON()].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
    // MARK: Installation
    
    /// - Returns: An NSURLRequest to create a given installation.
    class func phx_URLRequestForInstallationCreate(oauth: PhoenixOAuth, phoenix: Phoenix) -> NSURLRequest {
        assert(oauth.tokenType != .Application, "Only SDK/LoggedIn Users can call this request.")
        
        let installation = phoenix.installation
        let configuration = phoenix.internalConfiguration
        let url = configuration.baseURL!
            .phx_URLByAppendingRootIdentityPath()
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingApplications(configuration.applicationID)
            .phx_URLByAppendingInstallations()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = [installation.toJSON()].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    

    /// - returns: An NSURLRequest to update a given installation.
    class func phx_URLRequestForInstallationUpdate(oauth: PhoenixOAuth, phoenix: Phoenix) -> NSURLRequest {
        assert(oauth.tokenType != .Application, "Only SDK/LoggedIn Users can call this request.")
        
        let installation = phoenix.installation
        let configuration = phoenix.internalConfiguration
        let url = configuration.baseURL!
            .phx_URLByAppendingRootIdentityPath()
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingApplications(configuration.applicationID)
            .phx_URLByAppendingInstallations()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.HTTPMethod = HTTPRequestMethod.PUT.rawValue
        request.HTTPBody = [installation.toJSON()].phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
}



// MARK:- Analytics Module
internal extension NSURLRequest {
    
    class func phx_URLRequestForAnalytics(json: JSONDictionaryArray, oauth: PhoenixOAuth, phoenix: Phoenix) -> NSURLRequest {
        assert(oauth.tokenType != .Application, "Only SDK/LoggedIn Users can call this request.")
        
        let configuration = phoenix.internalConfiguration
        let url = configuration.baseURL!
            .phx_URLByAppendingRootAnalyticsPath()
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingEvents()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.HTTPMethod = HTTPRequestMethod.POST.rawValue
        request.HTTPBody = json.phx_toJSONData()
        
        return request.copy() as! NSURLRequest
    }
    
}



// MARK:- Location Module

internal extension NSURLRequest {
    
    /// - returns: An NSURLRequest to download geofences.
    class func phx_URLRequestForDownloadGeofences(oauth: PhoenixOAuth, phoenix: Phoenix) -> NSURLRequest {
        assert(oauth.tokenType != .Application, "Only SDK/LoggedIn Users can call this request.")
        
        let configuration = phoenix.internalConfiguration
        let url = configuration.baseURL!
            .phx_URLByAppendingRootLocationPath()
            .phx_URLByAppendingProjects(configuration.projectID)
            .phx_URLByAppendingGeofences()
        let request = NSMutableURLRequest(URL: url)
        
        request.allHTTPHeaderFields = phx_HTTPHeaders(oauth)
        request.HTTPMethod = HTTPRequestMethod.GET.rawValue
        
        // TODO: Add filtering
        
        return request.copy() as! NSURLRequest
    }
}