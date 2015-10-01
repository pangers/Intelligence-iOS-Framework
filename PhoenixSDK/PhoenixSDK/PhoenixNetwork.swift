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
        internal weak var phoenix: Phoenix!
        
        /// NSURLSession with default session configuration.
        internal private(set) lazy var sessionManager = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

        /// Contains concurrently executable operations for requests that rely on an authenticated session.
        /// Will be suspended if the authentication queue needs to perform authentications.
        internal lazy var workerQueue = NSOperationQueue()
        
        /// An operation queue to perform authentications. Will only enqueue an operation at a time as enforced by 'authenticationOperation != nil'.
        internal let authenticateQueue: NSOperationQueue

        /// Configuration passed through from Network initializer (assumed to be valid).
        internal let configuration: Phoenix.Configuration
        
        /// The authentication operation that is currently running or nil, if there are none in the queue at the moment.
        private var authenticationOperation: PhoenixOAuthPipeline?
        
        // MARK: Initializers
        
        /// Initialize new instance of Phoenix Networking class
        /// - Parameters:
        ///     - withConfiguration: The configuration object used.
        ///     - tokenStorage: The token storage to use.
        init(withConfiguration configuration: Phoenix.Configuration) {
            self.authenticateQueue = NSOperationQueue()
            self.authenticateQueue.maxConcurrentOperationCount = 1
            self.configuration = configuration
        }
        
        // MARK: Interception of responses
        
        /// Execute a request on the worker queue and performs the interception of
        /// it to handle authorization errors.
        ///
        /// - Parameters
        ///     - operation: The PhoenixNetworkRequestOperation to run.
        func executeNetworkOperation(operation: PhoenixOAuthOperation) {
            let initialBlock = operation.completionBlock
            operation.completionBlock = { [weak self] in
                defer {
                    initialBlock?()
                }
                if let this = self, httpResponse = operation.output?.response as? NSHTTPURLResponse where httpResponse.statusCode == 401 {
                    if operation.isMemberOfClass(PhoenixOAuthLoginOperation.self) || operation.isMemberOfClass(PhoenixOAuthRefreshOperation.self) || operation.isMemberOfClass(PhoenixOAuthValidateOperation.self) {
                        // Nothing we can do...
                        // TODO: Log error for developer
                        return
                    }
                    // No longer authenticated, try and authenticate
                    let pipeline = PhoenixOAuthPipeline(withOperations: [PhoenixOAuthRefreshOperation(), PhoenixOAuthLoginOperation()], oauth: operation.oauth, phoenix: this.phoenix)
                    this.enqueueOAuthPipeline(pipeline)
                }
            }
            workerQueue.addOperation(operation)
        }
        
        internal func enqueueOAuthPipeline(pipeline: PhoenixOAuthPipeline) {
            // No longer authenticated, try and authenticate
            workerQueue.suspended = true
            let oldCompletionBlock = pipeline.completionBlock
            pipeline.completionBlock = { [weak self, weak pipeline] in
                if pipeline != nil && pipeline?.operations.count == 0 {
                    // Login succeeeded
                    self?.workerQueue.suspended = false
                }
                oldCompletionBlock?()
            }
            authenticateQueue.addOperation(pipeline)
        }
    }
}


