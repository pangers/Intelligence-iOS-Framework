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

internal extension NSURLRequest {
    
    // MARK: Prepare request
    
    /// Add authentication headers to NSURLRequest.
    /// - Parameter authentication: Instance of Phoenix.Authentication containing valid accessToken
    /// - Returns: An NSURLRequest which is equal to this one, but adding the required headers to
    /// authenticate it against the backend.
    func phx_preparePhoenixRequest(withAuthentication authentication: Phoenix.Authentication) -> NSURLRequest {
        // Somehow the NSURLRequest is immutable (perhaps if subclassed?)
        guard let mutable = mutableCopy() as? NSMutableURLRequest else {
            assertionFailure("The mutable copy of this \(self.dynamicType) should return an NSMutableURLRequest.")
            return NSURLRequest()
        }
        
        // Get header fields from request or create new object
        var headerFields = mutable.allHTTPHeaderFields ?? [String: String]()
        
        // Check if content type is set, otherwise set to `application/json` by default
        headerFields[HTTPHeaderContentTypeKey] = headerFields[HTTPHeaderContentTypeKey] ?? HTTPHeaderApplicationJson
        
        // Set accept type to `application/json`
        headerFields[HTTPHeaderAcceptKey] = HTTPHeaderApplicationJson
        
        // If we have an access token append `Bearer` to header
        if let token = authentication.accessToken {
            headerFields[HTTPHeaderAuthorizationKey] = "Bearer \(token)"
        }
        
        mutable.allHTTPHeaderFields = headerFields
        
        return mutable
    }
    
    // MARK: URL Request factory for authentication
    
    /// - Parameters:
    ///     - authentication: Instance of Phoenix.Authentication optionally containing username/password/refreshToken.
    ///     - configuration: Instance of PhoenixConfigurationProtocol with valid clientID, clientSecret, and region.
    /// - Returns: An NSURLRequest that can be used to obtain an authentication token.
    class func phx_requestForAuthentication(authentication: Phoenix.Authentication, configuration: PhoenixConfigurationProtocol) -> NSURLRequest {
        
        if !authentication.anonymous {

            // Use either refresh token, or username and password parameters.
            if let _ = authentication.refreshToken {
                return phx_requestForAuthenticationWithRefreshToken(configuration, authentication: authentication)
            }
            else if let _ = authentication.username, _ = authentication.password {
                return phx_requestForAuthenticationWithUserCredentials(configuration, authentication: authentication)
            }
            else {
                assert(false, "Authentication.anonymous should guarantee this code is never reached.")
            }
            
        }
        else {
            return phx_requestForAuthenticationWithClientCredentials(configuration)
        }
    }
    
    /// - Parameters:
    ///     - configuration: Instance of PhoenixConfigurationProtocol with valid clientID, clientSecret, and region.
    /// - Returns: An anonymous client credentials NSURLRequest that can be used to obtain an authentication token.
    private class func phx_requestForAuthenticationWithClientCredentials(configuration:PhoenixConfigurationProtocol) -> NSURLRequest {
        let postQuery = "client_id=\(configuration.clientID)&client_secret=\(configuration.clientSecret)&grant_type=client_credentials"
        return phx_httpURLRequestForAuthentication(configuration, postQuery:postQuery)
    }
    
    /// - Parameters:
    ///     - configuration: Instance of PhoenixConfigurationProtocol with valid clientID, clientSecret, and region.
    ///     - authentication: Instance of Phoenix.Authentication optionally containing username/password/refreshToken.
    /// - Returns: A refresh token authentication NSURLRequest that can be used to obtain an authentication token.
    private class func phx_requestForAuthenticationWithRefreshToken(configuration:PhoenixConfigurationProtocol, authentication:Phoenix.Authentication) -> NSURLRequest {
        // Guard required values
        guard let refreshToken = authentication.refreshToken
            where configuration.clientID.isEmpty || configuration.clientSecret.isEmpty else {
                assertionFailure("Client ID and client Secret must not be empty. We also require a refresh token.")
                return NSURLRequest()
        }
        
        let postQuery = "client_id=\(configuration.clientID)&client_secret=\(configuration.clientSecret)&grant_type=password&refresh_token=\(refreshToken)"
        return phx_httpURLRequestForAuthentication(configuration, postQuery:postQuery)
    }
    
    /// - Parameters:
    ///     - configuration: Instance of PhoenixConfigurationProtocol with valid clientID, clientSecret, and region.
    ///     - authentication: Instance of Phoenix.Authentication optionally containing username/password/refreshToken.
    /// - Returns: An user credentials authentication NSURLRequest that can be used to obtain an authentication token.
    private class func phx_requestForAuthenticationWithUserCredentials(configuration:PhoenixConfigurationProtocol, authentication:Phoenix.Authentication) -> NSURLRequest {
        // Guard required values
        guard let username = authentication.username,
            password = authentication.password
            where configuration.clientID.isEmpty || configuration.clientSecret.isEmpty else {
                assertionFailure("Client ID and client Secret must not be empty. We also require username and password.")
                return NSURLRequest()
        }
        
        let postQuery = "client_id=\(configuration.clientID)&client_secret=\(configuration.clientSecret)&grant_type=password&username=\(username)&password=\(password)"
        return phx_httpURLRequestForAuthentication(configuration, postQuery:postQuery)
    }
    
    /// - Parameters:
    ///     - configuration: Instance of PhoenixConfigurationProtocol with valid clientID, clientSecret, and region.
    ///     - postQuery: The query to be used in the given OAuth request
    /// - Returns: An authentication NSURLRequest built using the passed configuration and postQuery.
    private class func phx_httpURLRequestForAuthentication(configuration: PhoenixConfigurationProtocol, postQuery:String) -> NSURLRequest {
        // Configure url
        if let url = NSURL(string: phx_oauthTokenURLPath(), relativeToURL: configuration.baseURL) {
            // Create URL encoded POST with query string
            let request = NSMutableURLRequest(URL: url)
            request.allHTTPHeaderFields = [HTTPHeaderContentTypeKey: HTTPHeaderApplicationFormUrlEncoded]
            request.HTTPMethod = HTTPRequestMethod.POST.rawValue
            request.HTTPBody = postQuery.dataUsingEncoding(NSUTF8StringEncoding)

            guard let finalRequest = request.copy() as? NSURLRequest else {
                assertionFailure("The copy method of the passed NSURLRequest should return an NSURLRequest instance")
                return NSURLRequest()
            }
            return finalRequest
        }

        assertionFailure("Couldn't create the authentication URL.")
        return NSURLRequest()
    }
    
    // MARK: User CRUD
    
    class func phx_httpURLRequestForCreateUser(withUser:PhoenixUser, configuration:PhoenixConfigurationProtocol) -> NSURLRequest {
        do {
            // Configure url
            if let url = NSURL(string: phx_usersURLPath(configuration.projectID), relativeToURL: configuration.baseURL) {
                
                // Create URL encoded POST with query string
                let request = NSMutableURLRequest(URL: url)
                request.allHTTPHeaderFields = [HTTPHeaderContentTypeKey: HTTPHeaderApplicationFormUrlEncoded]
                request.HTTPMethod = HTTPRequestMethod.POST.rawValue
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject([withUser.toJSON()], options: .PrettyPrinted)
                
                if let finalRequest = request.copy() as? NSURLRequest {
                    return finalRequest
                }
            }
        }
        catch {
            // The assertion will be called in case of exception
        }
        assertionFailure("Couldn't create the authentication URL.")
        return NSURLRequest()
    }
    
    // MARK: URL Paths
    
    /// - Returns: the path to the API endpoint to obtain an OAuth token.
    private class func phx_oauthTokenURLPath() -> String {
        return "\(phoenixIdentityAPIVersion)/oauth/token"
    }
    
    /// - Parameter projectId: The project Id that identifies the app. Provided by configuration.
    /// - Returns: the path to the API endpoint to obtain an OAuth token.
    private class func phx_usersURLPath(projectId:Int) -> String {
        return "\(phoenixIdentityAPIVersion)/projects/\(projectId)/users"
    }
}