//
//  PhoenixAPIOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

typealias PhoenixAPIResponse = (data: NSData?, response: NSURLResponse?, error: NSError?)

// Returned operation will be different than operation in some circumstances where tokens expire.
typealias PhoenixAPICallback = (returnedOperation: PhoenixAPIOperation) -> ()

private let BodyData = "Data"
private let BodyError = "error"
private let OfflineErrorCode = -1009

/// PhoenixAPIOperation is the abstract base class for any Phoenix API network operation, built on top of TSDOperation.
///
/// Inheritors should define their own main method, which should do the following:
/// - execute the call to the API endpoint
/// - call handleError so the deafult error handling behavior is executed
/// - optionally, you can execute custom loginc or additional error handling
///
/// Inheritors must conform to NSCopying.
internal class PhoenixAPIOperation: TSDOperation<PhoenixAPIResponse, PhoenixAPIResponse> {
    var shouldBreak: Bool = false
    
    // Times to try, excluding the inital try
    private var timesToRetry = UInt(2)
    
    // Contextually relevant information to pass between operations.
    var callback: PhoenixAPICallback?
    var oauth: PhoenixOAuthProtocol?
    var configuration: Phoenix.Configuration?
    var network: Network?
    var session: NSURLSession! {
        return network!.sessionManager
    }
    
    // MARK: Output Helpers
    
    func complete() {
        callback?(returnedOperation: self)
    }
    
    /// This function replaces the current output?.error with a sanitized error and is intended to be called
    /// by subclasses after the network request completes.
    /// When the network request returns a 401 status code, the handling is delegated to the handleUnauthorizedError function.
    /// Please read the handleUnauthorizedError documentation for a full explanation of the default behavior.
    func handleError() -> Bool {
        // This is NSURLSession's reponse code if we are offline
        if output?.error?.code == OfflineErrorCode {
            output?.error = NSError(code: RequestError.InternetOfflineError.rawValue)
            return true
        }
        
        if let httpResponse = output?.response as? NSHTTPURLResponse {
            if httpResponse.statusCode == HTTPStatusCode.Unauthorized.rawValue {
                handleUnauthorizedError()
                return true
            }
            else if httpResponse.statusCode == HTTPStatusCode.Forbidden.rawValue {
                handleForbbiddenError()
                return true
            }
            else if httpResponse.statusCode / 100 != 2 {
                handleUnhandledError(httpResponse.statusCode)
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
        let semaphore = dispatch_semaphore_create(0)
        
        // Attempt to get the pipeline for our OAuth token type.
        // Then execute the login pipeline before trying us again.
        // Shouldn't validate here, our token has expired.
        network?.getPipeline(forOAuth: self.oauth!, configuration: self.configuration!, shouldValidate: false, completion: { (pipeline) -> () in
            
            // Pipeline will be nil if it already exists in the queue.
            guard let pipeline = pipeline else {
                dispatch_semaphore_signal(semaphore)
                return
            }
            
            pipeline.callback = { [weak self, weak pipeline] (returnedOperation: PhoenixAPIOperation) in
                if pipeline?.output?.error == nil {
                    guard let timesToRetry = self?.timesToRetry else {
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    
                    if timesToRetry == 0 {
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    
                    // Add us again, should be called after pipeline succeeds.
                    let copiedOperation = self?.copy() as! PhoenixAPIOperation
                    
                    // Remove the current operations completion block
                    // Only the copiedOperation should complete
                    self?.completionBlock = nil
                    
                    // Take off this try
                    copiedOperation.timesToRetry = timesToRetry - 1
                    
                    copiedOperation.completionBlock = { [weak copiedOperation] in
                        copiedOperation?.complete()
                        
                        dispatch_semaphore_signal(semaphore)
                    }
                    
                    copiedOperation.start()
                }
                else {
                    // Call completion block for current operation.
                    self?.complete()
                    
                    dispatch_semaphore_signal(semaphore)
                }
            }
            
           pipeline.start()
        })
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    private func handleForbbiddenError() {
        output?.error = NSError(code: RequestError.Forbidden.rawValue)
    }
    
    private func handleUnhandledError(httpStatusCode: Int) {
        output?.error = NSError(code: RequestError.UnhandledError.rawValue, httpStatusCode:httpStatusCode)
    }
    
    /// Returns error if response contains an error in the data.
    func errorInData() -> String? {
        return self.output?.data?.phx_jsonDictionary?[BodyError] as? String
    }
    
    /// Returns all dictionaries in the 'Data' array of the output.
    func outputArray() -> JSONDictionaryArray? {
        guard let dataArray = self.output?.data?.phx_jsonDictionary?[BodyData] as? JSONDictionaryArray else {
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
