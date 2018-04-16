//
//  IntelligenceAPIOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

typealias IntelligenceAPIResponse = (data: Data?, response: URLResponse?, error: NSError?)

// Returned operation will be different than operation in some circumstances where tokens expire.
typealias IntelligenceAPICallback = (_ returnedOperation: IntelligenceAPIOperation) -> Void

private let BodyData = "Data"
private let BodyError = "error"
private let OfflineErrorCode = -1009

/// IntelligenceAPIOperation is the abstract base class for any Intelligence API network operation, built on top of TSDOperation.
///
/// Inheritors should define their own main method, which should do the following:
/// - execute the call to the API endpoint
/// - call handleError so the deafult error handling behavior is executed
/// - optionally, you can execute custom loginc or additional error handling
///
/// Inheritors must conform to NSCopying.
class IntelligenceAPIOperation: TSDOperation<IntelligenceAPIResponse, IntelligenceAPIResponse> {
    var shouldBreak: Bool = false

    // Times to try, excluding the inital try
    private var timesToRetry = UInt(2)

    // Contextually relevant information to pass between operations.
    var callback: IntelligenceAPICallback?
    var oauth: IntelligenceOAuthProtocol?
    var configuration: Intelligence.Configuration?
    var network: Network?
    var session: URLSession? {
        return network?.sessionManager
    }

    // MARK: Output Helpers

    func complete() {
        callback?(self)
    }

    /// This function replaces the current output?.error with a sanitized error and is intended to be called
    /// by subclasses after the network request completes.
    /// When the network request returns a 401 status code, the handling is delegated to the handleUnauthorizedError function.
    /// Please read the handleUnauthorizedError documentation for a full explanation of the default behavior.
    func handleError() -> Bool {
        // This is NSURLSession's reponse code if we are offline
        if output?.error?.code == OfflineErrorCode {
            output?.error = NSError(code: RequestError.internetOfflineError.rawValue)
            return true
        }

        if let httpResponse = output?.response as? HTTPURLResponse {
            if httpResponse.statusCode == HTTPStatusCode.unauthorized.rawValue {
                handleUnauthorizedError()
                let str = String(format: "UnAutherized error for request -- %@", (self.session?.description)!)
                sharedIntelligenceLogger.logger?.error(str)
                return true
            } else if httpResponse.statusCode == HTTPStatusCode.forbidden.rawValue {
                handleForbbiddenError()
                let str = String(format: "Handle forbbidden error -- %@", (self.session?.description)!)
                sharedIntelligenceLogger.logger?.error(str)
                return true
            } else if httpResponse.statusCode / 100 != 2 {
                handleUnhandledError(httpStatusCode: httpResponse.statusCode)
                let str = String(format: "UnHandled Error -- %@", (self.session?.description)!)
                sharedIntelligenceLogger.logger?.error(str)
                return true
            }
        }
        return false
    }

    /// This function is called when handleError recieves a 401.
    /// This function attempts to reauthenticate and then call the current operation again.
    /// If authentication fails the function completes.
    /// This cycle will continue until the current operation succeds or timesToRetry reaches 0.
    func handleUnauthorizedError() {
        let semaphore = DispatchSemaphore(value: 0)

        // Attempt to get the pipeline for our OAuth token type.
        // Then execute the login pipeline before trying us again.
        // Shouldn't validate here, our token has expired.
        network?.getPipeline(forOAuth: self.oauth!, configuration: self.configuration!, shouldValidate: false, completion: { (pipeline) -> Void in

            // Pipeline will be nil if it already exists in the queue.
            guard let pipeline = pipeline else {
                self.output?.error = NSError(code: RequestError.unauthorized.rawValue)
                let str = String(format: "OAuth Error -- %@", (self.output?.error?.description)!)
                sharedIntelligenceLogger.logger?.error(str)
                semaphore.signal()
                return
            }

            pipeline.callback = { [weak self, weak pipeline] (returnedOperation: IntelligenceAPIOperation) in
                if pipeline?.output?.error == nil {
                    guard let timesToRetry = self?.timesToRetry else {
                        self?.output?.error = NSError(code: RequestError.unauthorized.rawValue)

                        let str = String(format: "OAuth Error -- %@", (self?.output?.error?.description)!)
                        sharedIntelligenceLogger.logger?.error(str)
                        semaphore.signal()
                        return
                    }

                    if timesToRetry == 0 {
                        self?.output?.error = NSError(code: RequestError.unauthorized.rawValue)

                        let str = String(format: "OAuth Error -- %@", (self?.output?.error?.description)!)
                        sharedIntelligenceLogger.logger?.error(str)

                        semaphore.signal()
                        return
                    }

                    // Add us again, should be called after pipeline succeeds.
                    let copiedOperation = self?.copy() as! IntelligenceAPIOperation

                    // Remove the current operations completion block
                    // Only the copiedOperation should complete
                    self?.callback = nil

                    // Take off this try
                    copiedOperation.timesToRetry = timesToRetry - 1

                    copiedOperation.completionBlock = { [weak copiedOperation] in
                        copiedOperation?.complete()

                        semaphore.signal()
                    }

                    copiedOperation.start()
                } else {
                    // Forward the error from the OAuth pipeline to this pipeline
                    self?.output?.error = pipeline?.output?.error

                    let str = String(format: "OAuth Error -- %@", (self?.output?.error?.description)!)
                    sharedIntelligenceLogger.logger?.error(str)

                    semaphore.signal()
                }
            }

           pipeline.start()
        })

        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }

    private func handleForbbiddenError() {
        output?.error = NSError(code: RequestError.forbidden.rawValue)

        let str = String(format: "OAuth Error -- %@", (output?.error?.description)!)
        sharedIntelligenceLogger.logger?.error(str)
    }

    private func handleUnhandledError(httpStatusCode: Int) {
        output?.error = NSError(code: RequestError.unhandledError.rawValue, httpStatusCode: httpStatusCode)

        let str = String(format: "OAuth Error -- %@", (output?.error?.description)!)
        sharedIntelligenceLogger.logger?.error(str)
    }

    /// Returns error if response contains an error in the data.
    func errorInData() -> String? {
        return self.output?.data?.int_jsonDictionary?[BodyError] as? String
    }

    /// Returns all dictionaries in the 'Data' array of the output.
    func outputArray() -> JSONDictionaryArray? {
        guard let dataArray = self.output?.data?.int_jsonDictionary?[BodyData] as? JSONDictionaryArray else {
            return nil
        }
        return dataArray
    }

    /// Most API methods can use this helper to extract the first dictionary in the 'Data' array of output.
    func outputArrayFirstDictionary() -> JSONDictionary? {
        guard let dataDictionary = outputArray()?.first else {
            return nil
        }
        return dataDictionary
    }
}
