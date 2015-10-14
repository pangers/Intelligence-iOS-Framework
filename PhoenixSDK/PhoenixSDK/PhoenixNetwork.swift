//
//  PhoenixNetworking.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// The callback alias for internal purposes. The caller should parse this data into an object/struct rather
/// than giving this object back to the developer.
typealias PhoenixNetworkingCallback = (data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> ()

/// Enumeration containing the possible status to use.
internal enum HTTPStatus : Int {

    /// Success code
    case Success = 200

    // TODO: Rename these variables, as 401 is not always a Token Expired response and 403 is not always Token Invalid
    //       we need to interrogate the 'error' field in the JSON object that is returned to figure out what is actually the problem.

    /// 401, token expired, among other issues.
    case TokenExpired = 401

    /// 403, token invalid, among other issues
    case TokenInvalid = 403
}

// MARK: HTTP Method constants

/// An enumeration of the HTTP Methods available to use
internal enum HTTPRequestMethod : String {
    
    /// GET
    case GET = "GET"

    /// POST
    case POST = "POST"

    /// PUT
    case PUT = "PUT"
}

internal extension Phoenix {
    
    /// Acts as a Network manager for the Phoenix SDK, encapsulates authentication requests.
    internal final class Network {
        
        // MARK: Instance variables
        
        /// A link to the owner of this Network class (Phoenix) used for propagating errors upwards.
        weak internal var phoenix: Phoenix?
        
        /// NSURLSession with default session configuration.
        private(set) internal lazy var sessionManager = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

        /// Contains concurrently executable operations for requests that rely on an authenticated session.
        /// Will be suspended if the authentication queue needs to perform authentications.
        internal lazy var workerQueue = NSOperationQueue()
        
        /// An operation queue to perform authentications. Will only enqueue an operation at a time as enforced by 'authenticationOperation != nil'.
        internal let authenticateQueue: NSOperationQueue

        /// Configuration passed through from Network initializer (assumed to be valid).
        private let configuration: Phoenix.Configuration
        
        /// The current phoenix authentication.
        internal let authentication: Authentication
        
        /// The authentication operation that is currently running or nil, if there are none in the queue at the moment.
        private var authenticationOperation:AuthenticationRequestOperation?
        
        /// - Returns: true if the SDK is currently authenticated (anonymously or otherwise).
        internal var isAuthenticated: Bool {
            return !authentication.requiresAuthentication
        }
        
        // MARK: Initializers
        
        /// Initialize new instance of Phoenix Networking class
        /// - Parameters:
        ///     - withConfiguration: The configuration object used.
        ///     - tokenStorage: The token storage to use.
        init(withConfiguration configuration: Phoenix.Configuration, tokenStorage:TokenStorage) {
            self.authenticateQueue = NSOperationQueue()
            self.authenticateQueue.maxConcurrentOperationCount = 1
            self.authentication = Authentication(withTokenStorage: tokenStorage)
            self.configuration = configuration
        }
        
        // MARK: Interception of responses
        
        /// Checks authentication responses from the API. If an error is located, the authentication
        /// will be expired or invalidated.
        ///
        /// Currently intercepts:
        ///   - 401: token_expired (EXPIRE token, need to refresh)
        ///   - 403: invalid_token (INVALID access, cannot use this method)
        ///
        /// - Parameters:
        ///     - data: The data that was obtained from the backend.
        ///     - response: The NSURLResponse from the backend.
        ///     - error: The NSError of the request.
        /// - Returns: True if the call had an authentication
        private func checkAuthenticationErrorInResponse(data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> Bool {
            guard let httpResponse = response else {
                return false
            }
            
            switch httpResponse.statusCode {
                
                // 'token_expired' in 'error' field of response
            case HTTPStatus.TokenExpired.rawValue:
                // TODO: It seems that the server can return 401 for any reason related to improper
                // configuration or token expiry (we need to check 'error' field matches 'token_expired' to determine action.
                authentication.clearAccessToken()

                // 'invalid_token' in 'error' field of response
            case HTTPStatus.TokenInvalid.rawValue:
                fallthrough
                
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
            let operation = PhoenixNetworkRequestOperation(withSession: sessionManager, request: request, authentication: authentication)
            
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
        ///     - operation: The PhoenixNetworkRequestOperation to run.
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
                if this.checkAuthenticationErrorInResponse(operation.output?.data, response: operation.output?.response, error: operation.error) {
                    // Token invalid, try to authenticate again
                    this.enqueueAuthenticationOperationIfRequired()
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
        internal func enqueueAuthenticationOperationIfRequired() -> Bool {
            // If we already have an authentication operation we do not need to schedule another one.
            if !authentication.requiresAuthentication {
                return false
            }
            createAuthenticationOperation()
            
            // Suspend worker queue until authentication succeeds
            workerQueue.suspended = true
            
            return true
        }
        
        /// Attempt to authenticate, handles 200 internally (updating refresh_token, access_token and expires_in).
        /// - Parameter callback: Contains data, response, and error information from request.
        /// - Returns: `nil` or `Phoenix.AuthenticationRequestOperation` depending on if authentication is necessary (determined by `authentication` objects state).
        private func createAuthenticationOperation() {
            if authenticationOperation != nil { return }
            // If the request cannot be build we should exit.
            // This may need to raise some sort of warning to the developer (currently
            // only due to misconfigured properties - which should be enforced by Phoenix initializer).
            authenticationOperation = Phoenix.AuthenticationRequestOperation(network: self, configuration: configuration) { [weak self] (json) -> () in
                self?.authentication.update(withJSON: json)
                self?.didCompleteAuthenticationOperation()
            }
            authenticateQueue.addOperation(authenticationOperation!)
        }
        
        /// Called once an authentication operation finishes, to handle its response.
        /// - Parameter authenticationOperation: The operation that just finished.
        private func didCompleteAuthenticationOperation() {
            defer {
                authenticationOperation = nil
            }
            guard let operation = authenticationOperation else {
                return
            }
            let response = operation.output?.response
            let data = operation.output?.data
            var error = operation.error
            
            defer {
                // Continue worker queue if we have authentication object
                workerQueue.suspended = !self.isAuthenticated
                
                // If the worker queue is suspended, cancel all its tasks
                if workerQueue.suspended {
                    for operation in workerQueue.operations {
                        if let operation = operation as? PhoenixNetworkRequestOperation {
                            operation.authenticationFailed()
                        }
                    }
                }
                
                // Authentication object will be nil if we cannot parse the response.
                if authentication.requiresAuthentication == true {
                    // An exception is raised to the developer.
                    if error == nil {
                        error = NSError(domain: RequestError.domain, code: RequestError.RequestFailedError.rawValue, userInfo: nil)
                    }
                    phoenix?.errorCallback?(error!)
                }
            }
            
            // Regardless of how we hit this method, we should update our authentication headers
            guard let _ = data?.phx_jsonDictionary,
                httpResponse = response
                where httpResponse.statusCode == HTTPStatus.Success.rawValue else {
                    // Clear tokens if response is unreadable or unsuccessful.
                    authentication.reset()
                    return
            }
        }
    }
}


