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

internal enum HTTPStatusCode: Int {
    case Success = 200
    case Unauthorized = 401
    case Forbidden = 403
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
        
        internal let queue: NSOperationQueue
        
        /// A link to the owner of this Network class (Phoenix) used for propagating errors upwards.
        internal weak var phoenix: Phoenix!
        
        /// NSURLSession with default session configuration.
        internal private(set) lazy var sessionManager = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

        /// Configuration passed through from Network initializer (assumed to be valid).
        internal var configuration: Phoenix.Configuration {
            return phoenix.internalConfiguration
        }
        
        // MARK: Initializers
        
        /// Initialize new instance of Phoenix Networking class
        init() {
            self.queue = NSOperationQueue()
            self.queue.maxConcurrentOperationCount = 1
        }
        
        /// Return all queued OAuth operations (excluding pipeline operations).
        private func queuedOAuthOperations() -> [PhoenixOAuthOperation] {
            return queue.operations.filter({
                $0.isMemberOfClass(PhoenixOAuthPipeline.self) == false &&
                    $0.isKindOfClass(PhoenixOAuthOperation.self) == true })
                .map({ $0 as! PhoenixOAuthOperation })
        }
        
        
        // MARK: Interception of responses
        
        func enqueueOperation(operation: PhoenixOAuthOperation) {
            let initialBlock = operation.completionBlock
            operation.completionBlock = { [weak self] in
                // Check if our request failed.
                if let httpResponse = operation.output?.response as? NSHTTPURLResponse
                    where httpResponse.statusCode == HTTPStatusCode.Unauthorized.rawValue
                {
                    guard let network = self else { return }
                    
                    // Token is no longer valid and cannot be refreshed without user input. 
                    // Do not try again. Alert developer.
                    if operation.oauth?.tokenType == .LoggedInUser && operation.isMemberOfClass(PhoenixOAuthPipeline.self) {
                        // TODO: Alert developer
                        return
                    }
                    
                    // Token is no longer valid, lets try and refresh, if that fails login again.
                    let pipeline = PhoenixOAuthPipeline(withOperations: [PhoenixOAuthRefreshOperation(), PhoenixOAuthLoginOperation()],
                        oauth: operation.oauth, phoenix: network.phoenix)
                    
                    
                    // Iterate all queued OAuth operations (excluding pipeline operations).
                    network.queuedOAuthOperations().forEach({ (oauthOp) -> () in
                        // Make each operation dependant on this new pipeline if the token types match.
                        if oauthOp.oauth != nil && oauthOp.oauth?.tokenType == pipeline.oauth?.tokenType {
                            oauthOp.addDependency(pipeline)
                        }
                    })
                    
                    // Add original operation again, should be called after pipeline succeeds.
                    pipeline.queuePriority = .VeryHigh
                    pipeline.completionBlock = { [weak pipeline, weak network] in
                        if pipeline?.output?.error == nil {
                            // Add original operation again, should be called after pipeline succeeds.
                            network?.queue.addOperation(operation)
                        } else {
                            // Call completion block for original operation.
                            initialBlock?()
                        }
                    }
                    
                    // Prevent looping by adding explicitly to queue here.
                    network.queue.addOperation(pipeline)
                }
            }
            
            // Enqueue original operation.
            self.queue.addOperation(operation)
        }
    }
}


