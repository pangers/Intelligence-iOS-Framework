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
public typealias PhoenixAuthenticationCallback = (authenticated: Bool) -> ()

// In case we need exponential backoff.
//private let maximumDelay = 5 * 60 // 5 minutes
//
//private func exponentialBackoff() -> ( block: (()->Bool) ) -> Void
//{
//    var delay = 3
//    
//    func backoff ( block:( () -> Bool) ) {
//        
//        if !block() {
//            sleep(UInt32(delay))
//            
//            delay = min(maximumDelay, delay*2)
//            
//            backoff(block)
//        }
//        
//    }
//    
//    return backoff
//}

internal extension Phoenix {

    /// Operation to authenticate the user based on the received SDK configuration and Authentication.
    /// Will keep as the output of the operation a struct containing the data and the NSHTTPURLResponse
    /// In the error property, the error obtained from the network request will be offered.
    ///
    /// In order to use the callback approach (in which more than one callback can be notified),
    /// **the completion block must not be overridden**. If it is, the callbacks won't be notified of the 
    /// outcome of the operation.
    class AuthenticationRequestOperation : TSDOperation<NSURLRequest, (data:NSData?, response:NSHTTPURLResponse?)> {
        
        /// The URL session
        private let urlSession:NSURLSession
        
        /// The authentication object
        private let authentication:Phoenix.Authentication
        
        /// The callback objects that will be notified upon completion.
        private var callbacks:[PhoenixAuthenticationCallback] = []
        
        /// Default initializer
        /// - Parameters: 
        ///     - session: An NSURLSession to use for the requests.
        ///     - authentication: The authentication to use.
        ///     - configuration: The SDK configuration
        init(session:NSURLSession, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol) {
            self.urlSession = session
            self.authentication = authentication
            
            super.init()
            
            // If the request cannot be build we should exit.
            // This may need to raise some sort of warning to the developer (currently
            // only due to misconfigured properties - which should be enforced by Phoenix initializer).
            let request = NSURLRequest.phx_requestForAuthentication(authentication, configuration: configuration),
                preparedRequest = request.phx_preparePhoenixRequest(withAuthentication: authentication)
            
            self.input = preparedRequest
            
            // Set the completion block to call the callbacks.
            self.completionBlock = { [weak self] in
                guard let this = self else {
                    return
                }
                
                for callback in this.callbacks {
                    callback(authenticated: !this.authentication.requiresAuthentication)
                }
                
                this.callbacks = []
            }
        }
        
        /// Performs a request oeration
        override func main() {
            assert(self.input != nil, "Can't execute an Authentication operation with no request.")
            
//          Exponential backoff. Deactivated to avoid locking an account. See `
//            let backoff = exponentialBackoff()
//            backoff(block:requestAuthentication)
            
            if !requestAuthentication() {
                cancel()
            }
        }
        
        /// Actually executes the request and returns true if it successfully loaded the
        /// authentication response.
        func requestAuthentication() -> Bool {
            guard let request = input else {
                assert(false, "Can't execute an Authentication operation with no request.")
            }

            let (data, response, error) = urlSession.phx_executeSynchronousDataTaskWithRequest(request)
            
            self.error = error
            self.output = (data:data, response:response as? NSHTTPURLResponse)
            
            guard let jsonDictionary = data?.phx_jsonDictionary else {
                return false
            }
            
            if !self.authentication.loadAuthorizationFromJSON(jsonDictionary) {
                return false
            }
            
            return !self.authentication.requiresAuthentication
        }
        
        /// Adds a callback to the list of callbacks to be notified.
        /// It will be strongly held until the operation finishes.
        func addCallback(callback:PhoenixAuthenticationCallback) {
            if self.finished {
                callback(authenticated: !self.authentication.requiresAuthentication)
            }
            else {
                callbacks += [callback]
            }
        }
        
    }
}
