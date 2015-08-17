//
//  NetworkRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Allows to perform a request operation, receiving as input an NSURLRequest, and yielding
/// as output a struct with the data and the response. In the operation error the error of the request can be fetched.
internal class PhoenixNetworkRequestOperation : TSDOperation<NSURLRequest, (data:NSData?, response:NSHTTPURLResponse?)> {
    
    /// The URL session to use
    private let urlSession:NSURLSession
    
    /// The request that will be executed
    private let request:NSURLRequest
    
    /// The Phoenix authentication to prepare the request with.
    internal let authentication:Phoenix.Authentication
    
    /// Only used by 'getUserMe' and is the access_token we receive from the 'login' and is discarded immediately after this call.
    internal var disposableLoginToken: String?
    
    /// Default initializer with all required parameters
    init(withSession session:NSURLSession, request:NSURLRequest, authentication:Phoenix.Authentication) {
        self.urlSession = session
        self.request = request
        self.authentication = authentication
    }
    
    /// Default initializer, Network contains urlSession and authentication objects.
    init(withNetwork network: Phoenix.Network, request: NSURLRequest) {
        self.urlSession = network.sessionManager
        self.request = request
        self.authentication = network.authentication
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        // Mutate request, adding bearer token
        let preparedRequest = request.phx_preparePhoenixRequest(withAuthentication: self.authentication, disposableLoginToken: disposableLoginToken)
        
        let (data, response, error) = urlSession.phx_executeSynchronousDataTaskWithRequest(preparedRequest)
        
        // TODO: Remove Logging
        // Once we know exactly what we are getting back from the server
        // and can handle it appropriately, currently things are a bit ambiguous
        // so exposing the data we have received will help us define action plans
        // for how to deal with the response.
        //
        // Such as:
        // "This account is locked due to an excess of invalid authentication attempts"
        // on a login request, we should stop trying to login since this is unrecoverable
        // until resolved on the back-end.
        //
        if let statusCode = (response as? NSHTTPURLResponse)?.statusCode, path = request.URL?.lastPathComponent {
            print("Status: \(statusCode) - \(path)")
            if (statusCode != 200) {
                if let json = data?.phx_jsonDictionary {
                    print("Data: \(json)")
                }
            }
        }
        
        self.error = error
        self.output = (data:data, response:response as? NSHTTPURLResponse)
        
        if let statusCode = self.output?.response?.statusCode where statusCode != 200 {
            self.error = NSError(domain: RequestError.domain, code:RequestError.RequestFailedError.rawValue, userInfo: nil)
        }
    }
    
    /// Called when the authentication operation failed while this operation
    /// was in the queue. It is responsible to cancel itself, set its error,
    /// and call its completion block.
    func authenticationFailed() {
        cancel()
        
        if !self.finished {
            self.error = NSError(domain: RequestError.domain,code:RequestError.AuthenticationFailedError.rawValue,userInfo:nil)
            completionBlock?()
        }
    }

    // MARK:- Helpers
    
    /// Most API methods can use this helper to extract the first dictionary in the 'Data' array of output.
    func getFirstDataDictionary() -> JSONDictionary? {
        guard let dataArray = self.output?.data?.phx_jsonDictionary?["Data"] as? JSONArray,
            dataDictionary = dataArray.first as? JSONDictionary else {
                return nil
        }
        return dataDictionary
    }
}
