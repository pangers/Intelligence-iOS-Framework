//
//  PhoenixNetworking.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

@objc public protocol PhoenixNetworkDelegate {
    func authenticationFailed(data: NSData?, response: NSURLResponse?, error: NSError?)
}


/// Alias for an array loaded from a JSON object.
typealias JSONArray = [AnyObject]

/// Alias for a dictionary loaded from a JSON object.
typealias JSONDictionary = [String: AnyObject]

public typealias PhoenixNetworkingCallback = (data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> ()

public typealias PhoenixAuthenticationCallback = (authenticated: Bool) -> ()

// MARK: Status code constants
let HTTPStatusSuccess = 200
let HTTPStatusTokenExpired = 401
let HTTPStatusTokenInvalid = 403

// MARK: HTTP Method constants
let HTTPPOSTMethod = "POST"

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
        private var authentication: Authentication
        
        /// Static operation queue containing only one authentication operation at a time, enforced by 'authenticationOperation != nil'.
        private let authenticateQueue: NSOperationQueue
        
        var isAuthenticated:Bool {
            return !authentication.requiresAuthentication
        }
        
        var delegate:PhoenixNetworkDelegate?
        
        // MARK: Initializers
        
        /// Initialize new instance of Phoenix Networking class
        init(withConfiguration configuration: Configuration) {
            self.authenticateQueue = NSOperationQueue()
            self.authenticateQueue.maxConcurrentOperationCount = 1
            self.authentication = Authentication()
            self.configuration = configuration
        }
        
        // MARK: Interception of responses
        
        /// Checks authentication responses from the API. If an error is located, the authentication
        /// will be expired or invalidated.
        ///
        /// Currently intercepts:
        ///   - 401: token_expired (EXPIRE token, need to refresh)
        ///   - 403: invalid_token (NULL out token, need to reauthenticate)
        ///
        /// - Parameters:
        ///     - data: The data that was obtained from the backend.
        ///     - response: The NSURLResponse from the backend.
        ///     - error: The NSError of the request.
        /// - Returns: True if the call had an authentication
        private func checkAuthentication(data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> Bool {
            guard let httpResponse = response else {
                return false
            }
            
            switch httpResponse.statusCode {
                
                // 'token_expired' in 'error' field of response
            case HTTPStatusTokenExpired:
                // TODO: It seems that the server can return 401 for any reason related to improper
                // configuration or token expiry (we need to check 'error' field matches 'token_expired' to determine action.
                authentication.expireAccessToken()

                // 'invalid_token' in 'error' field of response
            case HTTPStatusTokenInvalid:
                authentication.invalidateTokens()
                
            default:
                return false
            }

            return true
        }
        
        /// Execute a request on the worker queue and performs the interception of
        /// it to handle authorization errors.
        ///
        /// - Parameters
        ///     - request: NSURLRequest with a valid URL.
        ///     - callback: Block/function to call once executed.
        func executeRequest(request: NSURLRequest, callback: PhoenixNetworkingCallback) {
            let operation = PhoenixNetworkRequestOperation(withSession: sessionManager, withRequest: request, withAuthentication: authentication)
            operation.completionBlock = {
                // Other error code can fallthrough to caller who implements callback func to handle.
                callback(data: operation.output?.data, response: operation.output?.response, error: operation.error)
            }
            
            executeNetworkOperation(operation)
        }
        
        /// Execute a request on the worker queue and performs the interception of
        /// it to handle authorization errors.
        ///
        /// - Parameters
        ///     - request: NSURLRequest with a valid URL.
        ///     - callback: Block/function to call once executed.
        func executeNetworkOperation(operation: PhoenixNetworkRequestOperation) {
            let initialBlock = operation.completionBlock
            
            operation.completionBlock = { [weak self] in
                
                defer {
                    if let block = initialBlock {
                        block()
                    }
                }
                
                guard let this = self else {
                    return
                }
                
                // Intercept the callback, handling 401 and 403
                if this.checkAuthentication(operation.output?.data, response: operation.output?.response, error: operation.error) {
                    // Token invalid, try to authenticate again
                    this.enqueueAuthenticationOperationIfRequired()
                    
                    // TODO: Reschedule the operation.
                }
            }
            
            enqueueRequestOperation(operation)
        }
        
        /// Enqueue operation in worker queue, will suspend worker queue if authentication is required.
        /// - Parameter operation: Operation created using
        private func enqueueRequestOperation(operation: PhoenixNetworkRequestOperation) {
            // This method may suspend worker queue
            enqueueAuthenticationOperationIfRequired()
            // Enqueue operation
            workerQueue.addOperation(operation)
        }
        
        
        // MARK:- Authentication
        
        /// Enqueues an authentication operation if needed
        /// - Returns: true if the operation was needed and has been enqueued.
        private func enqueueAuthenticationOperationIfRequired(callback:PhoenixNetworkingCallback? = nil) -> Bool {
            // If we already have an authentication operation we do not need to schedule another one.
            if !authentication.requiresAuthentication {
                
                if let block = callback {
                    block(authenticated: !authentication.requiresAuthentication)
                }
                return false
            }

            if let authenticationOperation = authenticateQueue.operations[0] as? AuthenticationRequestOperation {
                authenticationOperation.addCallback(callback)
                return false
            }
            
            let authOp = createAuthenticationOperation(callback)
            
            // Suspend worker queue until authentication succeeds
            workerQueue.suspended = true
            
            // Schedule authentication call
            authenticateQueue.addOperation(authOp)
            
            return true
        }
        
        /// Attempt to authenticate, handles 200 internally (updating refresh_token, access_token and expires_in).
        /// - Parameter callback: Contains data, response, and error information from request.
        /// - Returns: `nil` or `Phoenix.AuthenticationRequestOperation` depending on if authentication is necessary (determined by `authentication` objects state).
        private func createAuthenticationOperation(callback: PhoenixNetworkingCallback?) -> Phoenix.AuthenticationRequestOperation {
            // If the request cannot be build we should exit.
            // This may need to raise some sort of warning to the developer (currently
            // only due to misconfigured properties - which should be enforced by Phoenix initializer).
            let authenticationOperation = Phoenix.AuthenticationRequestOperation(session: sessionManager, authentication: authentication, configuration: configuration)
            
            authenticationOperation.completionBlock = { [weak self] in
                self?.didCompleteAuthenticationOperation(authenticationOperation, callback:callback)
            }
            
            return authenticationOperation
        }
        
        func didCompleteAuthenticationOperation(authenticationOperation:Phoenix.AuthenticationRequestOperation, callback: PhoenixNetworkingCallback?) {
            let response = authenticationOperation.output?.response
            let data = authenticationOperation.output?.data
            let error = authenticationOperation.error
            
            defer {
                // Continue worker queue if we have authentication object
                workerQueue.suspended = authenticateQueue.operationCount > 0
                
                // Execute callback with data from request
                if let block = callback {
                    block(data: data, response: response, error: error)
                }
                
                // Authentication object will be nil if we cannot parse the response.
                if authentication.requiresAuthentication == true {
                    // PSDK-26: #4 - When I open the sample app, And the /token endpoint is not available (404 error)
                    // PSDK-26: #5 - When I open the sample app, And the /token endpoint returns a 401 Unauthorised
                    // An exception is raised to the developer, And the SDK does not automatically attempt to get a token again
                    delegate?.authenticationFailed(data, response: response, error: error)
                }
            }
            
            // Regardless of how we hit this method, we should update our authentication headers
            guard let json = data?.phx_jsonDictionary,
                httpResponse = response
                where httpResponse.statusCode == HTTPStatusSuccess &&
                    authentication.loadAuthorizationFromJSON(json) == true else {
                    // TODO: Invalid response
                    return
            }
        }

        // TODO: Remove this method (hack - since we have no API calls yet)
        func tryLogin(callback: PhoenixAuthenticationCallback?) {
            enqueueAuthenticationOperationIfRequired(callback)
        }
    }
}


