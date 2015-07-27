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

public typealias PhoenixNetworkingCallback = (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()

extension Phoenix {
    class Network {
        
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
        
        
        private lazy var workerQueue = NSOperationQueue()
        private lazy var sessionManager = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        private let config: Phoenix.Configuration
        
        private let authentication: Phoenix.Authentication
        private var authenticationOperation: NSOperation?
        private let authenticateQueue: NSOperationQueue
        
        /// Initialize new instance of Phoenix Networking class
        init(withConfiguration configuration: Phoenix.Configuration) {
            authenticateQueue = NSOperationQueue()
            authenticateQueue.maxConcurrentOperationCount = 1
            config = configuration
            authentication = Phoenix.Authentication()
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
                    authentication.expireAccessToken()
                    // Token expired, try to refresh
                    fallthrough
                case HTTPStatusTokenInvalid:   // 'invalid_token' in 'error' field of response
                    authentication.invalidateTokens()
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
                    // TODO: Handle fail
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
            if authenticationOperation == nil {
                if let request = NSURLRequest.requestForAuthentication(authentication, configuration: config) {
                    let op = createRequestOperation(request, callback: { [weak self] (data, response, error) -> () in
                        // Regardless of how we hit this method, we should update our authentication headers
                        if let httpResponse = response as? NSHTTPURLResponse, this = self where httpResponse.statusCode == HTTPStatusSuccess {
                            guard let json = data?.jsonDictionary, accessToken = json["access_token"] as? String, expiresIn = json["expires_in"] as? Double where accessToken.isEmpty == false && expiresIn > 0 else {
                                // TODO: Fail invalid response, retry?
                                print("Invalid response")
                                return
                            }
                            if let refreshToken = json["refresh_token"] as? String {
                                // Optionally returned by server (only for 'password' grant type?)
                                this.authentication.refreshToken = refreshToken
                            }
                            // Store new state
                            this.authentication.accessToken = accessToken
                            this.authentication.expiresIn(expiresIn)
                            
                            // Continue worker queue
                            this.workerQueue.suspended = false
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
            }
            return nil
        }
        
        /// Handles enqueuing an authentication operation, returns false if unnecessary.
        private func enqueueAuthenticationOperationIfRequired() -> Bool {
            guard let authOp = createAuthenticationOperationIfNecessary({ (data, response, error) -> () in
                // Try to login with user credentials
            }) else {
                return false
            }
            
            // Suspend worker queue
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
    private func mutateRequest(withAuthentication authentication: Phoenix.Authentication) -> NSURLRequest? {
        guard let mutable = mutableCopy() as? NSMutableURLRequest else {
            return nil
        }
        let applicationJSON = "application/json"
        var headerFields = ["Accept": applicationJSON, "Content-Type": applicationJSON]
        if let token = authentication.accessToken {
            headerFields["Authorization"] = "Bearer \(token)"
        }
        mutable.allHTTPHeaderFields = headerFields
        return mutable
    }
    
    /// Request with URL constructed using current Authentication and Configuration.
    /// - Parameter authentication: Instance of Phoenix.Authentication optionally containing username/password/refreshToken.
    /// - Parameter configuration: Instance of Phoenix.Configuration with valid clientID, clientSecret, and region.
    class func requestForAuthentication(authentication: Phoenix.Authentication, configuration: Phoenix.Configuration) -> NSURLRequest? {
        // Only pass back request if we require authentication
        if authentication.requiresAuthentication == false {
            return nil
        }
        var urlQuery = "identity/v1/oauth/token?client_id=\(configuration.clientID)&client_secret=\(configuration.clientSecret)"
        let grantType: String
        if authentication.anonymous == false {
            grantType = "password"
            if authentication.refreshToken == nil {
                urlQuery += "&username=\(authentication.username!)&password=\(authentication.password)"
            }
        } else {
            grantType = "client_credentials"
        }
        urlQuery += "&grant_type=\(grantType)"
        if authentication.refreshToken != nil {
            urlQuery += "&refresh_token=\(authentication.refreshToken!)"
        }
        if let url = NSURL(string: urlQuery, relativeToURL: configuration.baseURL) {
            return NSURLRequest(URL: url)
        }
        return nil
    }
}