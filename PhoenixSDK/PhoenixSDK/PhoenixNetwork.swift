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

/// Acts as a Network manager for the Phoenix SDK, encapsulates authentication requests.
internal final class Network {
    
    /// Delegate must be set before startup is called on modules.
    internal var delegate: PhoenixInternalDelegate!
    
    /// Provider responsible for serving OAuth information.
    internal var oauthProvider: PhoenixOAuthProvider!
    
    /// NSURLSession with default session configuration.
    internal private(set) lazy var sessionManager = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    internal let queue: NSOperationQueue
    
    // MARK: Initializers
    
    /// Initialize new instance of Phoenix Networking class
    init(delegate: PhoenixInternalDelegate, oauthProvider: PhoenixOAuthProvider) {
        self.queue = NSOperationQueue()
        self.queue.maxConcurrentOperationCount = 1
        self.delegate = delegate
        self.oauthProvider = oauthProvider
    }
    
    /// Return all queued OAuth operations (excluding pipeline operations).
    private func queuedOAuthOperations() -> [PhoenixOAuthOperation] {
        return queue.operations.filter({
            $0.isMemberOfClass(PhoenixOAuthPipeline.self) == false &&
                $0.isKindOfClass(PhoenixOAuthOperation.self) == true })
            .map({ $0 as! PhoenixOAuthOperation })
    }
    
    /// Return all queued OAuth operations (excluding pipeline operations).
    private func queuedOAuthPipelines() -> [PhoenixOAuthPipeline] {
        return queue.operations.filter({
            $0.isMemberOfClass(PhoenixOAuthPipeline.self) == true })
            .map({ $0 as! PhoenixOAuthPipeline })
    }
    
    // MARK: Interception of responses
    
    /// Caller's responsibility to enqueue this operation.
    /// - parameter tokenType:  Type of token we need.
    /// - returns: Return PhoenixOAuthPipeline for given token type.
    internal func getPipeline(forOAuth oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, completion: (PhoenixOAuthPipeline?) -> ()) {
        if oauth.tokenType == .SDKUser && (oauth.username == nil || oauth.password == nil) {
            assertionFailure("User should have been created in startup()")
            completion(nil)
            return
        }
        
        // Check if queued operations doesn't already contain a pipeline for this OAuth token type.
        if self.queuedOAuthPipelines()
            .filter({ $0.oauth != nil && $0.oauth?.tokenType != oauth.tokenType })
            .count > 0
        {
            // Nothing we can do, we are already logging in with this token type.
            completion(nil)
            return
        }
        
        // Token is no longer valid, lets try and refresh, if that fails login again.
        let pipeline = PhoenixOAuthPipeline(withOperations: [PhoenixOAuthRefreshOperation(), PhoenixOAuthLoginOperation()],
            oauth: oauth, configuration: configuration, network: self)
        
        // Iterate all queued OAuth operations (excluding pipeline operations).
        queuedOAuthOperations().forEach({ (oauthOp) -> () in
            // Make each operation dependant on this new pipeline if the token types match.
            if oauthOp.oauth != nil && oauthOp.oauth?.tokenType == oauth.tokenType {
                oauthOp.addDependency(pipeline)
            }
        })
        
        // Set priority of pipeline to high, to move it above other requests (that aren't in progress already).
        pipeline.queuePriority = .VeryHigh
        
        completion(pipeline)
    }
    
    internal func enqueueOperation(operation: PhoenixOAuthOperation) {
        // This method will enqueue an operation and override the completion handler
        // to cover the case that we require reauthentication (HTTP 401). It will then
        // execute the initial completion block when appropriate.
        let initialBlock = operation.completionBlock
        operation.completionBlock = { [weak self] in
            // Check if our request failed.
            guard let httpResponse = operation.output?.response as? NSHTTPURLResponse
                where httpResponse.statusCode == HTTPStatusCode.Unauthorized.rawValue else
            {
                // Cannot be handled as an unauthorized error.
                // Call completion block for original operation.
                initialBlock?()
                return
            }
            guard let network = self else { return }
            
            if operation.oauth?.tokenType == .LoggedInUser && operation.isMemberOfClass(PhoenixOAuthPipeline.self) {
                // Token is no longer valid and cannot be refreshed without user input.
                // This will occur if refreshToken fails.
                // Do not try again. Alert developer.
                self?.delegate?.userLoginRequired()
                return
            }
            
            // Attempt to get the pipeline for this operation's OAuth token type.
            // Then execute the login pipeline before trying this operation again.
            self?.getPipeline(forOAuth: operation.oauth!, configuration: operation.configuration!, completion: { (pipeline) -> () in
                // Pipeline will be nil if it already exists in the queue.
                guard let pipeline = pipeline else { return }
                
                pipeline.completionBlock = { [weak pipeline, weak network] in
                    if pipeline?.output?.error == nil {
                        // Add original operation again, should be called after pipeline succeeds.
                        network?.queue.addOperation(operation)
                    } else {
                        // Call completion block for original operation.
                        initialBlock?()
                    }
                }
                
                // Add explicitly to queue here, rather than calling enqueueOperation again (which would result in loop).
                network.queue.addOperation(pipeline)
            })
        }
        
        // Enqueue original operation.
        self.queue.addOperation(operation)
    }
}
