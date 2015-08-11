//
//  AuthenticationRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Defines an authentication callback, which only returns whether the request
/// has successfully authenticated the user or not.
internal typealias PhoenixAuthenticationCallback = (json: JSONDictionary?) -> ()

internal extension Phoenix {

    /// Operation to authenticate the user based on the received SDK configuration and Authentication.
    /// Will keep as the output of the operation a struct containing the data and the NSHTTPURLResponse
    /// In the error property, the error obtained from the network request will be offered.
    ///
    /// In order to use the callback approach (in which more than one callback can be notified),
    /// **the completion block must not be overridden**. If it is, the callbacks won't be notified of the 
    /// outcome of the operation.
    internal final class AuthenticationRequestOperation : TSDOperation<NSURLRequest, (data:NSData?, response:NSHTTPURLResponse?)> {
        
        var json: JSONDictionary?
        
        /// The URL session
        private let urlSession:NSURLSession
        
        /// The authentication object
        private let authentication: PhoenixAuthenticationProtocol
        
        /// The callback objects that will be notified upon completion.
        private let callback: PhoenixAuthenticationCallback
        
        convenience init(network: Phoenix.Network, configuration: Phoenix.Configuration, username: String? = nil, password: String? = nil, callback: PhoenixAuthenticationCallback) {
            self.init(session: network.sessionManager, authentication: network.authentication, configuration: configuration, username: username, password: password, callback: callback)
        }
        
        /// Default initializer
        /// - Parameters: 
        ///     - session: An NSURLSession to use for the requests.
        ///     - authentication: The authentication to use.
        ///     - configuration: The SDK configuration
        ///     - username: Optional username to send for login.
        ///     - password: Optional password to send for login.
        ///     - callback: Callback to trigger on completion.
        init(session:NSURLSession, authentication: PhoenixAuthenticationProtocol, configuration: Phoenix.Configuration, username: String? = nil, password: String? = nil, callback: PhoenixAuthenticationCallback) {
            self.urlSession = session
            self.authentication = authentication
            self.callback = callback
            
            super.init()
            
            // If the request cannot be build we should exit.
            // This may need to raise some sort of warning to the developer (currently
            // only due to misconfigured properties - which should be enforced by Phoenix initializer).
            
            let request: NSURLRequest
            if let username = username, password = password {
                request = NSURLRequest.phx_requestForAuthenticationWithUserCredentials(configuration, username: username, password: password)
            } else {
                request = NSURLRequest.phx_requestForAuthenticationWithClientCredentials(configuration)
            }
            let preparedRequest = request.phx_preparePhoenixRequest(withAuthentication: authentication)
            
            self.input = preparedRequest
            
            self.completionBlock = { [weak self] in
                self?.callback(json: self?.json)
            }
        }
        
        /// Performs a request oeration
        override func main() {
            assert(self.input != nil, "Can't execute an Authentication operation with no request.")
            guard let request = input else {
                assert(false, "Can't execute an Authentication operation with no request.")
                return
            }
            
            let (data, response, error) = urlSession.phx_executeSynchronousDataTaskWithRequest(request)
            
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
            
            guard let jsonDictionary = data?.phx_jsonDictionary, accessToken = jsonDictionary[accessTokenKey] as? String where !accessToken.isEmpty else {
                return
            }
            self.json = jsonDictionary
        }
    }
}
