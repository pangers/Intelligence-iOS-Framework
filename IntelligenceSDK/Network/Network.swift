//
//  IntelligenceNetworking.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// An enumeration of the HTTP Methods available to use
enum HTTPRequestMethod: String {
    /// HTTP GET
    case get = "GET"
    /// HTTP POST
    case post = "POST"
    /// HTTP PUT
    case put = "PUT"
    /// HTTP DELETE
    case delete = "DELETE"
}

enum HTTPStatusCode: Int {
    case success = 200
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
}

/// Acts as a Network manager for the Intelligence SDK, encapsulates authentication requests.
final class Network: NSObject, URLSessionDelegate {

    /// Delegate must be set before startup is called on modules.
    var delegate: IntelligenceInternalDelegate!

    let authenticationChallengeDelegate: URLSessionDelegate

    /// Provider responsible for serving OAuth information.
    var oauthProvider: IntelligenceOAuthProvider!

    /// NSURLSession with default session configuration.
    private(set) var sessionManager: URLSession?
    let queue: OperationQueue

    // MARK: Initializers

    /// Initialize new instance of Intelligence Networking class
    init(delegate: IntelligenceInternalDelegate, authenticationChallengeDelegate: URLSessionDelegate, oauthProvider: IntelligenceOAuthProvider) {
        self.queue = OperationQueue()
        self.queue.maxConcurrentOperationCount = 1
        self.delegate = delegate
        self.authenticationChallengeDelegate = authenticationChallengeDelegate
        self.oauthProvider = oauthProvider

        super.init()

        self.sessionManager = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        self.authenticationChallengeDelegate.urlSession?(session, didReceive: challenge, completionHandler: completionHandler)
    }

    /// Return all queued operations (excluding pipeline operations).
    func queuedOperations() -> [IntelligenceAPIOperation] {
        return queue.operations.filter({
            !($0 is IntelligenceAPIPipeline) &&
                $0 is IntelligenceAPIOperation })
            .map({ $0 as! IntelligenceAPIOperation })
    }

    /// Return all queued operations (excluding pipeline operations).
    func queuedPipelines() -> [IntelligenceAPIPipeline] {

        return queue.operations.filter({
            $0 is IntelligenceAPIPipeline}) as! [IntelligenceAPIPipeline]
    }

    // MARK: Interception of responses

    /// Caller's responsibility to enqueue this operation.
    /// - parameter tokenType:  Type of token we need.
    /// - returns: Return IntelligenceAPIPipeline for given token type.
    func getPipeline(forOAuth oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, shouldValidate: Bool = true, completion: (IntelligenceAPIPipeline?) -> Void) {

        if oauth.tokenType == .loggedInUser && (oauth.username == nil || oauth.password == nil) {
            assertionFailure("loggedInUser must have username and password!")
            completion(nil)
            return
        }

        // Check if queued operations doesn't already contain a pipeline for this OAuth token type.
        if self.queuedPipelines()
            .filter({ $0.oauth != nil && $0.oauth?.tokenType == oauth.tokenType })
            .count > 0 {
            // Nothing we can do, we are already logging in with this token type.
            completion(nil)
            return
        }

        // If shouldValidate == false, the token is no longer valid, lets try and refresh, if that fails login again.
        var operations = [IntelligenceOAuthRefreshOperation(), IntelligenceOAuthLoginOperation()]
        if shouldValidate {
            operations.insert(IntelligenceOAuthValidateOperation(), at: 0)
        }

        let pipeline = IntelligenceAPIPipeline(withOperations: operations,
            oauth: oauth, configuration: configuration, network: self)

        // Iterate all queued operations (excluding pipeline operations).
        queuedOperations().forEach({ (op) -> Void in
            // Make each operation dependant on this new pipeline if the token types match.
            if op.oauth != nil && op.oauth?.tokenType == oauth.tokenType {
                op.addDependency(pipeline)
            }
        })

        // Set priority of pipeline to high, to move it above other requests (that aren't in progress already).
        pipeline.queuePriority = .veryHigh

        completion(pipeline)
    }

    func enqueueOperation(operation: IntelligenceAPIOperation) {
        // This method will enqueue an operation and
        // execute the initial completion block when appropriate.
        operation.completionBlock = { [weak operation] in
            operation?.complete()
        }

        self.queue.addOperation(operation)
    }
}
