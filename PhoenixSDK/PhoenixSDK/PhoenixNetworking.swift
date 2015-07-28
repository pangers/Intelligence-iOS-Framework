//
//  PhoenixNetworking.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

private let HTTPStatusSuccess = 200
private let HTTPStatusTokenExpired = 401
private let HTTPStatusTokenInvalid = 403

private let HTTPHeaderAcceptKey = "Accept"
private let HTTPHeaderAuthorizationKey = "Authorization"
private let HTTPHeaderContentTypeKey = "Content-Type"
private let HTTPHeaderApplicationJson = "application/json"
private let HTTPHeaderApplicationFormUrlEncoded = "application/x-www-form-urlencoded"

public typealias PhoenixNetworkingCallback = (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()

extension Phoenix {
    class Network {
        // TODO: Define a retry policy, something like...
        // Call
        // -> Auth (has token?)
        //   -> Success
        //     -> Try call
        //       -> Failure
        //         -> Try refresh existing token
        //           -> Failure
        //             -> Authenticate
        //               -> Success
        //                 -> Return to call
        //   -> Failure
        //     -> Send credentials (anonymous or user)
        //       -> Success
        //         -> Return to call
        //       -> Failure
        //         -> Cannot continue (try later?)
        
        /// Contains concurrently executable operations for requests that rely on an authenticated session.
        private lazy var workerQueue = NSOperationQueue()
        /// - Returns: NSURLSession with default session configuration.
        private lazy var sessionManager = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        /// Configuration passed through from Phoenix initializer (must be valid).
        private let config: Configuration
        
        /// Authentication object will be configured on response of an oauth/token call or initialized from NSUserDefaults.
        private var authentication: Authentication?
        /// There should only ever be one authentication NSOperation.
        private var authenticationOperation: NSOperation?
        /// Static operation queue containing only one authentication operation at a time, enforced by 'authenticationOperation != nil'.
        private let authenticateQueue: NSOperationQueue
        
        /// Initialize new instance of Phoenix Networking class
        init(withConfiguration configuration: Configuration) {
            authenticateQueue = NSOperationQueue()
            authenticateQueue.maxConcurrentOperationCount = 1
            authentication = Authentication()   // may be nil
            config = configuration
        }
        
        /// Intercept a callback before passing it on, if true we will not pass it on.
        /// Currently intercepts 401 and 403.
        private func interceptCallback(data: NSData?, response: NSURLResponse?, error: NSError?) -> Bool {
            // If error is 401, enqueue authentication operation (or piggyback on existing)
            if let httpResponse = response as? NSHTTPURLResponse {
                // Intercepted responses:
                // - 'token_expired' is 401 (EXPIRE token, need to refresh)
                // - 'invalid_token' is 403 (NULL out token, need to reauthenticate)
                switch httpResponse.statusCode {
                case HTTPStatusTokenExpired:   // 'token_expired' in 'error' field of response
                    // TODO: It seems that the server can return 401 for any reason related to improper configuration or token expiry (we need to check 'error' field matches 'token_expired' to determine action.
                    authentication?.expireAccessToken()
                    // Token expired, try to refresh
                    fallthrough
                case HTTPStatusTokenInvalid:   // 'invalid_token' in 'error' field of response
                    authentication?.invalidateTokens()
                    // Token invalid, try to authenticate again
                    enqueueAuthenticationOperationIfRequired()
                    // Do not handle elsewhere
                    return true
                default:
                    // Pass callback through to other logic
                    return false
                }
            }
            return false
        }
        
        /// Create a request operation from a NSURLRequest.
        /// - Parameter request: NSURLRequest to perform
        /// - Parameter callback: Block/function to call once complete.
        private func createRequestOperation(request: NSURLRequest, callback: PhoenixNetworkingCallback) -> NSOperation {
            let operation = NSBlockOperation { [weak self] () -> Void in
                // Mutate request, adding bearer token
                guard let this = self, authenticatedRequest = request.mutateRequest(withAuthentication: this.authentication) else {
                    // Self has been invalidated or url request is immutable (somehow?)
                    return
                }
                let semaphore = dispatch_semaphore_create(0)
                let dataTask = this.sessionManager.dataTaskWithRequest(authenticatedRequest) { (data, response, error) in
                    callback(data: data, response: response, error: error)
                    dispatch_semaphore_signal(semaphore)
                }
                dataTask.resume()
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            }
            return operation
        }
        
        /// Execute a request on the worker queue.
        /// - Parameter request: NSURLRequest with a valid URL.
        /// - Parameter callback: Block/function to call once executed.
        func executeRequest(request: NSURLRequest, callback: PhoenixNetworkingCallback) {
            let operation = createRequestOperation(request) { [weak self] (data, response, error) in
                // Intercept the callback, handling 401 and 403
                if self?.interceptCallback(data, response: response, error: error) == false {
                    // Other error code can fallthrough to caller who implements callback func to handle.
                    callback(data: data, response: response, error: error)
                }
            }
            enqueueRequestOperation(operation)
        }
        
        // TODO: Remove this method (hack - since we have no API calls yet)
        func tryLogin(callback: PhoenixNetworkingCallback) {
            let blockOp = NSBlockOperation { () -> Void in
                print("Started block")
            }
            enqueueRequestOperation(blockOp)
        }
        
        /// Enqueue operation in worker queue, will suspend worker queue if authentication is required.
        /// - Parameter operation: Operation created using
        private func enqueueRequestOperation(operation: NSOperation) {
            // This method may suspend worker queue
            enqueueAuthenticationOperationIfRequired()
            // Enqueue operation
            workerQueue.addOperation(operation)
        }
        
        
        // MARK:- Authentication
        
        /// Attempt to authenticate, handles 200 internally (updating refresh_token, access_token and expires_in).
        /// - Parameter callback: Contains data, response, and error information from request.
        /// - Returns: `nil` or `NSOperation` depending on if authentication is necessary (determined by `authentication` objects state).
        private func createAuthenticationOperationIfNecessary(callback: PhoenixNetworkingCallback) -> NSOperation? {
            // If we already have an authentication operation we do not need to schedule another one.
            if authenticationOperation != nil {
                return nil
            }
            // If the request cannot be build we should exit. This may need to raise some sort of warning to the developer (currently only due to misconfigured properties - which should be enforced by Phoenix initializer).
            guard let request = NSURLRequest.requestForAuthentication(authentication, configuration: config) else {
                return nil
            }
            // Create authentication request operation
            let op = createRequestOperation(request, callback: { [weak self] (data, response, error) -> () in
                // Regardless of how we hit this method, we should update our authentication headers
                if let httpResponse = response as? NSHTTPURLResponse, this = self where httpResponse.statusCode == HTTPStatusSuccess {
                    guard let json = data?.jsonDictionary, auth = Authentication(json: json) else {
                        // TODO: Handle this...
                        print("Invalid response")
                        return
                    }
                    this.authentication = auth
                    
                    print("Logged in")
                    
                    // Continue worker queue if we have authentication object
                    this.workerQueue.suspended = this.authentication == nil
                }
                // Execute callback with data from request
                callback(data: data, response: response, error: error)
            })
            op.completionBlock = { [weak self] in
                // Clear pointer
                self?.authenticationOperation = nil
            }
            return op
        }
        
        /// Handles enqueuing an authentication operation, returns false if unnecessary.
        private func enqueueAuthenticationOperationIfRequired() -> Bool {
            guard let authOp = createAuthenticationOperationIfNecessary({ (data, response, error) -> () in
                // Try to login with user credentials
            }) else {
                return false
            }
            
            // Suspend worker queue until authentication succeeds
            workerQueue.suspended = true
            
            // Schedule authentication call
            authenticationOperation = authOp
            authenticateQueue.addOperation(self.authenticationOperation!)
            return true
        }
    }
}


extension NSURLRequest {
    /// Add authentication headers to NSURLRequest.
    /// - Parameter authentication: Instance of Phoenix.Authentication containing valid accessToken
    func mutateRequest(withAuthentication authentication: Phoenix.Authentication?) -> NSURLRequest? {
        guard let mutable = mutableCopy() as? NSMutableURLRequest else {
            // Somehow the NSURLRequest is immutable (perhaps if subclassed?)
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
    
    /// Request with URL constructed using current Authentication and Configuration.
    /// - Parameter authentication: Instance of Phoenix.Authentication optionally containing username/password/refreshToken.
    /// - Parameter configuration: Instance of Phoenix.Configuration with valid clientID, clientSecret, and region.
    class func requestForAuthentication(authentication: Phoenix.Authentication?, configuration: Phoenix.Configuration) -> NSURLRequest? {
        // Only pass back request if we require authentication
        if authentication?.requiresAuthentication == false {
            return nil
        }
        // Configure client ID and secret
        var postQuery = "client_id=\(configuration.clientID)&client_secret=\(configuration.clientSecret)"
        // Set default grant type
        var grantType: String = "client_credentials"
        if let auth = authentication {
            // Check if authentication is currently anonymous (username and password are empty)
            if auth.anonymous == false {
                // Change grant type
                grantType = "password"
                // Use either refresh token, or username and password parameters.
                if let token = auth.refreshToken {
                    postQuery += "&refresh_token=\(token)"
                } else {
                    guard let username = auth.username, password = auth.password else {
                        // This path should never occur (auth.anonymous checks if these values are set)
                        fatalError()
                    }
                    postQuery += "&username=\(username)&password=\(password)"
                }
            }
        }
        // Append grant type
        postQuery += "&grant_type=\(grantType)"
        // Configure url
        if let url = NSURL(string: "identity/v1/oauth/token", relativeToURL: configuration.baseURL) {
            // Create URL encoded POST with query string
            let request = NSMutableURLRequest(URL: url)
            request.allHTTPHeaderFields = [HTTPHeaderContentTypeKey: HTTPHeaderApplicationFormUrlEncoded]
            request.HTTPMethod = "POST"
            request.HTTPBody = postQuery.dataUsingEncoding(NSUTF8StringEncoding)
            return request.copy() as? NSURLRequest
        }
        return nil
    }
}