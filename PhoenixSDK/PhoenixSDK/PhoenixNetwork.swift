//
//  PhoenixNetworking.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// The network delegate. Currently only shows authentication failed.
@objc(PHXPhoenixNetworkDelegate) public protocol PhoenixNetworkDelegate {
    
    optional
    
    /// Called when an authentication failure occurs in the Phoenix SDK.
    /// - Parameters:
    ///     - error: The error that occured
    func phoenixAuthenticationFailed(error: NSError?)
}

/// The callback alias for internal purposes. The caller should parse this data into an object/struct rather
/// than giving this object back to the developer.
typealias PhoenixNetworkingCallback = (data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> ()

// MARK: Status code constants

/// Enumeration containing the possible status to use.
enum HTTPStatus : Int {

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
enum HTTPRequestMethod : String {
    
    /// GET
    case GET = "GET"

    /// POST
    case POST = "POST"
}

internal extension Phoenix {
    
    /// Acts as a Network manager for the Phoenix SDK, encapsulating authenticationg requests within it.
    final class Network {
        
        // MARK: Instance variables

        /// NSURLSession with default session configuration.
        private(set) internal lazy var sessionManager = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

        /// Contains concurrently executable operations for requests that rely on an authenticated session.
        /// Will be suspended if the authentication queue needs to perform authentications.
        private lazy var workerQueue = NSOperationQueue()
        
        /// An operation queue to perform authentications. Will only enqueue an operation at a time as enforced by 'authenticationOperation != nil'.
        private let authenticateQueue: NSOperationQueue

        /// Configuration passed through from Network initializer (assumed to be valid).
        private let configuration: PhoenixConfigurationProtocol
        
        /// The current phoenix authentication.
        private(set) internal var authentication:Authentication
        
        /// The authentication operation that is currently running or nil, if there are none in the queue at the moment.
        private var authenticationOperation:AuthenticationRequestOperation?
        
        /// - Returns: true if username and password are unset.
        var isAnonymous: Bool {
            return authentication.anonymous
        }
        
        /// - Returns: true if the SDK is currently authenticated (anonymously or otherwise).
        var isAuthenticated:Bool {
            return !authentication.requiresAuthentication
        }
        
        /// - Returns: true if the SDK is currently authenticated with a username and password.
        var isLoggedIn: Bool {
            // Refresh token is only set when we are logged in, therefore if we check that we have a username, password and refreshToken that should fulfil the requirements of being logged in.
            return !authentication.requiresAuthentication &&
                !isAnonymous &&
                authentication.refreshToken != nil
        }
        
        /// A delegate to receive notifications from the network manager.
        weak var delegate:PhoenixNetworkDelegate?
        
        // MARK: Initializers
        
        /// Initialize new instance of Phoenix Networking class
        /// - Parameters:
        ///     - withConfiguration: The configuration object used.
        init(withConfiguration configuration: PhoenixConfigurationProtocol) {
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
        private func checkAuthenticationErrorInResponse(data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> Bool {
            guard let httpResponse = response else {
                return false
            }
            
            switch httpResponse.statusCode {
                
                // 'token_expired' in 'error' field of response
            case HTTPStatus.TokenExpired.rawValue:
                // TODO: It seems that the server can return 401 for any reason related to improper
                // configuration or token expiry (we need to check 'error' field matches 'token_expired' to determine action.
                authentication.expireAccessToken()

                // 'invalid_token' in 'error' field of response
            case HTTPStatus.TokenInvalid.rawValue:
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
        /// - Parameters:
        ///     - callback: The callback that will receive a call once the authentication finishes.
        /// - Returns: true if the operation was needed and has been enqueued.
        private func enqueueAuthenticationOperationIfRequired(callback:PhoenixAuthenticationCallback? = nil) -> Bool {
            // If we already have an authentication operation we do not need to schedule another one.
            if !authentication.requiresAuthentication {
                
                if let block = callback {
                    block(authenticated: true)
                }
                return false
            }

            if let authOp = authenticationOperation {
                if let block = callback {
                    authOp.addCallback(block)
                }
                return false
            }
            authenticationOperation = createAuthenticationOperation(callback)
            
            // Suspend worker queue until authentication succeeds
            workerQueue.suspended = true
            
            // Schedule authentication call
            authenticateQueue.addOperation(authenticationOperation!)
            
            return true
        }
        
        /// Attempt to authenticate, handles 200 internally (updating refresh_token, access_token and expires_in).
        /// - Parameter callback: Contains data, response, and error information from request.
        /// - Returns: `nil` or `Phoenix.AuthenticationRequestOperation` depending on if authentication is necessary (determined by `authentication` objects state).
        private func createAuthenticationOperation(callback: PhoenixAuthenticationCallback?) -> Phoenix.AuthenticationRequestOperation {
            // If the request cannot be build we should exit.
            // This may need to raise some sort of warning to the developer (currently
            // only due to misconfigured properties - which should be enforced by Phoenix initializer).
            let authenticationOperation = Phoenix.AuthenticationRequestOperation(session: sessionManager, authentication: authentication, configuration: configuration)
            
            authenticationOperation.addCallback { [weak self] (authenticated) -> () in
                self?.didCompleteAuthenticationOperation(authenticationOperation)
            }
            
            if let block = callback {
                authenticationOperation.addCallback(block)
            }
            
            return authenticationOperation
        }
        
        /// Called once an authentication operation finishes, to handle its response.
        /// - Parameter authenticationOperation: The operation that just finished.
        private func didCompleteAuthenticationOperation(authenticationOperation:Phoenix.AuthenticationRequestOperation) {
            assert(authenticationOperation.finished)
            self.authenticationOperation = nil
            
            let response = authenticationOperation.output?.response
            let data = authenticationOperation.output?.data
            let error = authenticationOperation.error
            
            defer {
                // Continue worker queue if we have authentication object
                workerQueue.suspended = !self.isAuthenticated
                
                // Authentication object will be nil if we cannot parse the response.
                if authentication.requiresAuthentication == true {
                    // An exception is raised to the developer.
                    delegate?.phoenixAuthenticationFailed?(error)
                }
            }
            
            // Regardless of how we hit this method, we should update our authentication headers
            guard let json = data?.phx_jsonDictionary,
                httpResponse = response
                where httpResponse.statusCode == HTTPStatus.Success.rawValue else {
                    // Clear tokens if response is unreadable or unsuccessful.
                    logout()
                    return
            }
            authentication.loadAuthorizationFromJSON(json)
        }
        
        /// Attempt to authenticate with a username and password.
        /// - Parameters
        ///     - username: Username of account to attempt login with.
        ///     - password: Password associated with username.
        ///     - callback: Block/function to call once executed.
        func login(withUsername username: String, password: String, callback: PhoenixAuthenticationCallback) {
            authentication.configure(withUsername: username, password: password)
            enqueueAuthenticationOperationIfRequired(callback)
        }
        
        /// Clear all stored credentials and OAuth tokens, next request will be done anonymously after requesting a new OAuth token.
        func logout() {
            workerQueue.suspended = true
            authentication.reset()
        }
        
        // TODO: Remove this method (hack - since we have no API calls yet)
        func anonymousLogin(callback: PhoenixAuthenticationCallback? = nil) {
            authentication.username = nil
            authentication.password = nil
            authentication.invalidateTokens()
            enqueueAuthenticationOperationIfRequired(callback)
        }
    }
}


