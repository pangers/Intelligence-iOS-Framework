//
//  PhoenixNetworking.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Alias for an array loaded from a JSON object.
typealias JSONArray = [AnyObject]

/// Alias for a dictionary loaded from a JSON object.
typealias JSONDictionary = [String: AnyObject]

public typealias PhoenixNetworkingCallback = (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()

// MARK: Status code constants
let HTTPStatusSuccess = 200
let HTTPStatusTokenExpired = 401
let HTTPStatusTokenInvalid = 403

// MARK: HTTP Method constants
let HTTPPOSTMethod = "POST"

let defaultRequestRetries = 3

extension Phoenix {
    
    /// Wraps calls to the Phoenix API to assure that they are correctly authenticated.
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
        
        // MARK: Instance variables
        
        /// Contains concurrently executable operations for requests that rely on an authenticated session.
        private lazy var workerQueue = NSOperationQueue()
        
        /// NSURLSession with default session configuration.
        private lazy var sessionManager = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        /// Configuration passed through from Network initializer (assumed to be valid).
        private let configuration: Configuration
        
        /// Authentication object will be configured on response of an oauth/token call or initialized from NSUserDefaults.
        private var authentication: Authentication?
        
        /// There should only ever be one authentication NSOperation.
        private var authenticationOperation: NSOperation?
        
        /// Static operation queue containing only one authentication operation at a time, enforced by 'authenticationOperation != nil'.
        private let authenticateQueue: NSOperationQueue
        
        // MARK: Initializers
        
        /// Initialize new instance of Phoenix Networking class
        init(withConfiguration configuration: Configuration) {
            self.authenticateQueue = NSOperationQueue()
            self.authenticateQueue.maxConcurrentOperationCount = 1
            self.authentication = Authentication()   // may be nil
            self.configuration = configuration
        }
        
        // MARK: Interception of responses
        
        /// Intercept a callback before passing it on, if true we will not pass it on.
        /// Currently intercepts:
        ///   - 401: token_expired (EXPIRE token, need to refresh)
        ///   - 403: invalid_token (NULL out token, need to reauthenticate)
        ///
        /// - Parameters:
        ///     - data: The data that was obtained from the backend.
        ///     - response: The NSURLResponse from the backend.
        ///     - error: The NSError of the request.
        /// - Returns: True if the call has had to be intercepted due to an authentication error.
        private func interceptCallback(data: NSData?, response: NSURLResponse?, error: NSError?) -> Bool {
            // Guard for non HTTP URL Responses (should never occur).
            guard let httpResponse = response as? NSHTTPURLResponse else {
                return false
            }
            
            switch httpResponse.statusCode {
                
                // 'token_expired' in 'error' field of response
            case HTTPStatusTokenExpired:
                // TODO: It seems that the server can return 401 for any reason related to improper
                // configuration or token expiry (we need to check 'error' field matches 'token_expired' to determine action.
                authentication?.expireAccessToken()

                // 'invalid_token' in 'error' field of response
            case HTTPStatusTokenInvalid:
                authentication?.invalidateTokens()
                
            default:
                return false
            }

            return true
        }
        
        /// Create a request operation from a NSURLRequest that will run synchronously the call.
        /// The callback passed will handle the results of the HTTP call.
        /// - Parameters:
        ///     - request: NSURLRequest to perform
        ///     - callback: Block/function to call once complete. Must be synchronous, since it has
        ///                 a semaphore waiting for it to finish
        /// - Returns: The NSOperation created
        private func createRequestOperation(request: NSURLRequest, callback: PhoenixNetworkingCallback) -> NSOperation {
            
            let operation = NSBlockOperation { [weak self] () -> Void in
                // Mutate request, adding bearer token
                guard let this = self,
                    authenticatedRequest = request.phx_preparePhoenixRequest(withAuthentication: this.authentication) else {
                    // Self has been invalidated or url request is immutable (somehow?)
                    return
                }
                
                // Execute synchronously the network request.
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
        
        /// Execute a request on the worker queue and performs the interception of 
        /// it to handle authorization errors.
        ///
        /// - Parameters
        ///     - request: NSURLRequest with a valid URL.
        ///     - callback: Block/function to call once executed.
        func executeRequest(request: NSURLRequest, callback: PhoenixNetworkingCallback) {
            executeRequestWithRetries(request, callback: callback, retriesLeft: defaultRequestRetries)
        }
        
        private func executeRequestWithRetries(request:NSURLRequest, callback: PhoenixNetworkingCallback, retriesLeft: Int) {
            // Check retries
            if retriesLeft <= 0 {
                // TODO: Notify the callback of the auth error
//                callback(data: nil, response: nil, error: NSError(domain: , code: Int, userInfo: [NSObject : AnyObject]?))
                return
            }
            
            let operation = createRequestOperation(request) { [weak self] (data, response, error) in
                
                guard let this = self else {
                    return
                }
                
                // Intercept the callback, handling 401 and 403
                if this.interceptCallback(data, response: response, error: error) {
                    // Token invalid, try to authenticate again
                    this.enqueueAuthenticationOperationIfRequired()
                    this.executeRequestWithRetries(request, callback: callback, retriesLeft: retriesLeft-1)
                }
                else {
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
            // If we already have an authentication operation we do not need to schedule another one.
            if authenticationOperation != nil {
                return nil
            }
            
            // If the request cannot be build we should exit. 
            // This may need to raise some sort of warning to the developer (currently 
            // only due to misconfigured properties - which should be enforced by Phoenix initializer).
            guard let request = NSURLRequest.phx_requestForAuthentication(authentication, configuration: configuration) else {
                return nil
            }
            
            // Create authentication request operation
            let op = createRequestOperation(request, callback: { [weak self] (data, response, error) -> () in
                defer {
                    // Execute callback with data from request
                    callback(data: data, response: response, error: error)
                }
                
                guard let this = self else {
                    return
                }
                
                // Regardless of how we hit this method, we should update our authentication headers
                if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == HTTPStatusSuccess {
                        
                        guard let json = data?.phx_jsonDictionary, auth = Authentication(json: json) else {
                            // TODO: Handle this...
                            print("Invalid response")
                            return
                        }
                        
                        this.authentication = auth
                        
                        print("Logged in")
                }
            })
            
            op.completionBlock = { [weak self] in
                guard let this = self else {
                    return
                }
                
                // Clear pointer
                this.authenticationOperation = nil
            
                // Continue worker queue if we have authentication object
                this.workerQueue.suspended = (this.authentication != nil) ? this.authentication!.requiresAuthentication : true
            }
            
            return op
        }
        
        /// Enqueues an authentication operation if needed
        /// - Returns: true if the operation was needed and has been enqueued.
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
        
        // TODO: Remove this method (hack - since we have no API calls yet)
        func tryLogin(callback: PhoenixNetworkingCallback) {
            let blockOp = NSBlockOperation { () -> Void in
                print("Started block")
            }
            enqueueRequestOperation(blockOp)
        }
    }
}


