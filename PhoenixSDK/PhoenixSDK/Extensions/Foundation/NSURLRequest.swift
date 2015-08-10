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
    func phx_preparePhoenixRequest(withAuthentication authentication: PhoenixAuthenticationProtocol, temporaryAccessToken: String? = nil) -> NSURLRequest {
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
        if let token = temporaryAccessToken ?? authentication.accessToken {
            headerFields[HTTPHeaderAuthorizationKey] = "Bearer \(token)"
        }
        
        mutable.allHTTPHeaderFields = headerFields
        
        return mutable
    }
    
    // MARK: URL Request factory for authentication
    
    /// - Parameters:
    ///     - configuration: Instance of PhoenixConfigurationProtocol with valid clientID, clientSecret, and region.
    /// - Returns: An anonymous client credentials NSURLRequest that can be used to obtain an authentication token.
    class func phx_requestForAuthenticationWithClientCredentials(configuration: PhoenixConfigurationProtocol) -> NSURLRequest {
        if configuration.clientID.isEmpty || configuration.clientSecret.isEmpty {
            assertionFailure("Client ID and client Secret must not be empty. We also require username and password.")
            return NSURLRequest()
        }
        let postQuery = "client_id=\(configuration.clientID)&client_secret=\(configuration.clientSecret)&grant_type=client_credentials"
        return phx_httpURLRequestForAuthentication(configuration, postQuery:postQuery)
    }
    
    /// - Parameters:
    ///     - configuration: Instance of PhoenixConfigurationProtocol with valid clientID, clientSecret, and region.
    ///     - authentication: Instance of Phoenix.Authentication optionally containing username/password/refreshToken.
    /// - Returns: An user credentials authentication NSURLRequest that can be used to obtain an authentication token.
    class func phx_requestForAuthenticationWithUserCredentials(configuration: PhoenixConfigurationProtocol, username: String, password: String) -> NSURLRequest {
        if configuration.clientID.isEmpty || configuration.clientSecret.isEmpty {
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
    
    /// - Returns: An NSURLRequest to create the given user.
    /// - Parameters:
    ///     - withUser: The user to create.
    ///     - configuration: The configuratio to use.
    class func phx_httpURLRequestForCreateUser(withUser:Phoenix.User, configuration:PhoenixConfigurationProtocol) -> NSURLRequest {
        // Configure url
        if let url = NSURL(string: phx_usersURLPath(configuration.projectID), relativeToURL: configuration.baseURL) {
            
            // Create URL encoded POST with query string
            let request = NSMutableURLRequest(URL: url)
            request.allHTTPHeaderFields = [HTTPHeaderContentTypeKey: HTTPHeaderApplicationFormUrlEncoded]
            request.HTTPMethod = HTTPRequestMethod.POST.rawValue
            request.HTTPBody = [withUser.toJSON()].phx_toJSONData()
            
            if let finalRequest = request.copy() as? NSURLRequest {
                return finalRequest
            }
        }
        assertionFailure("Couldn't create the users URL.")
        return NSURLRequest()
    }
    
    class func phx_httpURLRequestForGetUserMe(configuration:PhoenixConfigurationProtocol) -> NSURLRequest {
        // Configure url
        if let url = NSURL(string: phx_usersMeURLPath(), relativeToURL: configuration.baseURL) {
            return NSURLRequest(URL: url)
        }
        assertionFailure("Couldn't create the users/me URL.")
        return NSURLRequest()
    }
    
    /// Creates the NSURLRequest to get the user id.
    /// - Parameters:
    ///     - userId: The Id of the user that we want to get.
    ///     - withConfiguration: The configuration that is being currently used.
    class func phx_httpURLRequestForGetUserById(userId:Int, withConfiguration configuration:PhoenixConfigurationProtocol) -> NSURLRequest {
        // Configure url
        if let url = NSURL(string: phx_usersURLPath(configuration.projectID) + "/\(userId)", relativeToURL: configuration.baseURL) {
            return NSURLRequest(URL: url)
        }
        assertionFailure("Couldn't create the users/me URL.")
        return NSURLRequest()
    }
    
    // MARK: URL Paths
    
    /// - Returns: the path to the API endpoint to obtain an OAuth token.
    private class func phx_oauthTokenURLPath() -> String {
        return "\(phoenixIdentityAPIVersion)/oauth/token"
    }
    
    /// - Returns: The path to get current user's information.
    private class func phx_usersMeURLPath() -> String {
        return "\(phoenixIdentityAPIVersion)/users/me"
    }
    
    /// - Parameter projectId: The project Id that identifies the app. Provided by configuration.
    /// - Returns: The path for most requests related to a user.
    private class func phx_usersURLPath(projectId:Int) -> String {
        return "\(phoenixIdentityAPIVersion)/projects/\(projectId)/users"
    }
}