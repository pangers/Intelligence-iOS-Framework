//
//  PhoenixNetworking.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// An enumeration of the HTTP Methods available to use
internal enum HTTPRequestMethod : String {
    /// HTTP GET
    case GET = "GET"
    /// HTTP POST
    case POST = "POST"
    /// HTTP PUT
    case PUT = "PUT"
    /// HTTP DELETE
    case DELETE = "DELETE"
}

internal enum HTTPStatusCode: Int {
    case Success = 200
    case MultipleChoices = 300
    case BadRequest = 400
    case Unauthorized = 401
    case Forbidden = 403
    case NotFound = 404
}

/// Acts as a Network manager for the Phoenix SDK, encapsulates authentication requests.
internal final class Network: NSObject, NSURLSessionDelegate {
    
    /// Delegate must be set before startup is called on modules.
    internal var delegate: PhoenixInternalDelegate!
    
    internal let authenticationChallengeDelegate: NSURLSessionDelegate
    
    /// Provider responsible for serving OAuth information.
    internal var oauthProvider: PhoenixOAuthProvider!
    
    /// NSURLSession with default session configuration.
    internal private(set) var sessionManager : NSURLSession?
    internal let queue: NSOperationQueue
    
    // MARK: Initializers
    
    /// Initialize new instance of Phoenix Networking class
    init(delegate: PhoenixInternalDelegate, authenticationChallengeDelegate: NSURLSessionDelegate, oauthProvider: PhoenixOAuthProvider) {
        self.queue = NSOperationQueue()
        self.queue.maxConcurrentOperationCount = 1
        self.delegate = delegate
        self.authenticationChallengeDelegate = authenticationChallengeDelegate;
        self.oauthProvider = oauthProvider
        
        super.init()
        
        self.sessionManager = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        self.authenticationChallengeDelegate.URLSession?(session, didReceiveChallenge: challenge, completionHandler: completionHandler)
    }
    
    /// Return all queued OAuth operations (excluding pipeline operations).
    internal func queuedOAuthOperations() -> [PhoenixOAuthOperation] {
        return queue.operations.filter({
            $0.isMemberOfClass(PhoenixOAuthPipeline.self) == false &&
                $0.isKindOfClass(PhoenixOAuthOperation.self) == true })
            .map({ $0 as! PhoenixOAuthOperation })
    }
    
    /// Return all queued OAuth operations (excluding pipeline operations).
    internal func queuedOAuthPipelines() -> [PhoenixOAuthPipeline] {
        return queue.operations.filter({
            $0.isMemberOfClass(PhoenixOAuthPipeline.self) == true })
            .map({ $0 as! PhoenixOAuthPipeline })
    }
    
    // MARK: Interception of responses
    
    /// Caller's responsibility to enqueue this operation.
    /// - parameter tokenType:  Type of token we need.
    /// - returns: Return PhoenixOAuthPipeline for given token type.
    internal func getPipeline(forOAuth oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, shouldValidate: Bool = true, completion: (PhoenixOAuthPipeline?) -> ()) {
        if oauth.tokenType == .SDKUser && (oauth.username == nil || oauth.password == nil) {
            assertionFailure("User should have been created in startup()")
            completion(nil)
            return
        }
        
        // Check if queued operations doesn't already contain a pipeline for this OAuth token type.
        if self.queuedOAuthPipelines()
            .filter({ $0.oauth != nil && $0.oauth?.tokenType == oauth.tokenType })
            .count > 0
        {
            // Nothing we can do, we are already logging in with this token type.
            completion(nil)
            return
        }
        
        // If shouldValidate == false, the token is no longer valid, lets try and refresh, if that fails login again.
        var operations = [PhoenixOAuthRefreshOperation(), PhoenixOAuthLoginOperation()]
        if shouldValidate {
            operations.insert(PhoenixOAuthValidateOperation(), atIndex: 0)
        }
        
        let pipeline = PhoenixOAuthPipeline(withOperations: operations,
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
        // This method will enqueue an operation and
        // execute the initial completion block when appropriate.
        operation.completionBlock = { [weak operation] in
            operation?.complete()
        }
        
        self.queue.addOperation(operation)
    }
}
