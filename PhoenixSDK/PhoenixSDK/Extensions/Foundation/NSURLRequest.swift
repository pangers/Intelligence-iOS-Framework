//
//  NSURLRequest.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 28/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

private let phoenixIdentityAPIVersion = "identity/v1"

private let HTTPHeaderAcceptKey = "Accept"
private let HTTPHeaderAuthorizationKey = "Authorization"
private let HTTPHeaderContentTypeKey = "Content-Type"
private let HTTPHeaderApplicationJson = "application/json"
private let HTTPHeaderApplicationFormUrlEncoded = "application/x-www-form-urlencoded"

extension NSURLRequest {
    
    // MARK: Prepare request
    
    /// Add authentication headers to NSURLRequest.
    /// - Parameter authentication: Instance of Phoenix.Authentication containing valid accessToken
    /// - Returns: An optional NSURLRequest which is equal to this one, but adding the required headers to 
    /// authenticate it against the backend.
    func preparePhoenixRequest(withAuthentication authentication: Phoenix.Authentication?) -> NSURLRequest? {
        // Somehow the NSURLRequest is immutable (perhaps if subclassed?)
        guard let mutable = mutableCopy() as? NSMutableURLRequest else {
            return nil
        }
        
        // Get header fields from request or create new object
        var headerFields = mutable.allHTTPHeaderFields ?? [String: String]()
        
        // Check if content type is set, otherwise set to `application/json` by default
        headerFields[HTTPHeaderContentTypeKey] = headerFields[HTTPHeaderContentTypeKey] ?? HTTPHeaderApplicationJson
        
        // Set accept type to `application/json`
        headerFields[HTTPHeaderAcceptKey] = HTTPHeaderApplicationJson
        
        // If we have an access token append `Bearer` to header
        if let token = authentication?.accessToken {
            headerFields[HTTPHeaderAuthorizationKey] = "Bearer \(token)"
        }
        
        mutable.allHTTPHeaderFields = headerFields
        
        return mutable
    }
    
    // MARK: URL Request factory
    
    /// Request with URL constructed using the passed Authentication and Configuration.
    /// - Parameters:
    ///     - authentication: Instance of Phoenix.Authentication optionally containing username/password/refreshToken.
    ///     - configuration: Instance of Phoenix.Configuration with valid clientID, clientSecret, and region.
    /// - Returns: An NSURLRequest that can be used to obtain an authentication token.
    class func requestForAuthentication(authentication: Phoenix.Authentication?, configuration: Phoenix.Configuration) -> NSURLRequest? {

        if let auth = authentication where !auth.anonymous {

            // Use either refresh token, or username and password parameters.
            if let _ = auth.refreshToken {
                return requestForAuthenticationWithRefreshToken(configuration, authentication: auth)
            }
            else if let _ = auth.username, _ = auth.password {
                return requestForAuthenticationWithUserCredentials(configuration, authentication: auth)
            }
            else {
                assert(false, "Authentication.anonymous should guarantee this code is never reached.")
            }
            
        }
        else {
            return requestForAuthenticationWithClientCredentials(configuration)
        }
    }
    
    private class func requestForAuthenticationWithClientCredentials(configuration:Phoenix.Configuration) -> NSURLRequest? {
        // Guard required values
        if configuration.clientID.isEmpty || configuration.clientSecret.isEmpty {
            return nil
        }
        
        let postQuery = "client_id=\(configuration.clientID)&client_secret=\(configuration.clientSecret)&grant_type=client_credentials"
        return httpURLRequestForAuthentication(configuration, postQuery:postQuery)
    }
    
    private class func requestForAuthenticationWithRefreshToken(configuration:Phoenix.Configuration, authentication:Phoenix.Authentication) -> NSURLRequest? {
        // Guard required values
        guard let refreshToken = authentication.refreshToken
            where configuration.clientID.isEmpty || configuration.clientSecret.isEmpty else {
                return nil
        }
        
        let postQuery = "client_id=\(configuration.clientID)&client_secret=\(configuration.clientSecret)&grant_type=password&refresh_token=\(refreshToken)"
        return httpURLRequestForAuthentication(configuration, postQuery:postQuery)
    }
    
    private class func requestForAuthenticationWithUserCredentials(configuration:Phoenix.Configuration, authentication:Phoenix.Authentication) -> NSURLRequest? {
        // Guard required values
        guard let username = authentication.username,
            let password = authentication.password
            where configuration.clientID.isEmpty || configuration.clientSecret.isEmpty else {
                return nil
        }
        
        let postQuery = "client_id=\(configuration.clientID)&client_secret=\(configuration.clientSecret)&grant_type=password&username=\(username)&password=\(password)"
        return httpURLRequestForAuthentication(configuration, postQuery:postQuery)
    }
    
    private class func httpURLRequestForAuthentication(configuration: Phoenix.Configuration, postQuery:String) -> NSURLRequest? {
        // Configure url
        if let url = NSURL(string: oauthTokenURLPath(), relativeToURL: configuration.baseURL) {
            // Create URL encoded POST with query string
            let request = NSMutableURLRequest(URL: url)
            request.allHTTPHeaderFields = [HTTPHeaderContentTypeKey: HTTPHeaderApplicationFormUrlEncoded]
            request.HTTPMethod = HTTPPOSTMethod
            request.HTTPBody = postQuery.dataUsingEncoding(NSUTF8StringEncoding)

            return request.copy() as? NSURLRequest
        }

        return nil
    }
    
    // MARK: URL Paths
    
    /// - Returns: the path to the API endpoint to obtain an OAuth token.
    private class func oauthTokenURLPath() -> String {
        return "\(phoenixIdentityAPIVersion)/oauth/token"
    }
}