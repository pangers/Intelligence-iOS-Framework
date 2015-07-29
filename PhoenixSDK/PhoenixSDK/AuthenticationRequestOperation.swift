//
//  AuthenticationRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

private let maximumDelay = 5 * 60 // 5 minutes

private func exponentialBackoff() -> ( block: (()->Bool) ) -> Void
{
    var delay = 3
    
    func backoff ( block:( () -> Bool) ) {
        
        if !block() {
            sleep(UInt32(delay))
            
            delay = min(maximumDelay, delay*2)
            
            backoff(block)
        }
        
    }
    
    return backoff
}

extension Phoenix {
    
    class AuthenticationRequestOperation : TSDOperation<NSURLRequest, (data:NSData?, response:NSHTTPURLResponse?)> {
        
        private let sessionManager:NSURLSession
        private let authentication:Phoenix.Authentication
        
        init?(session:NSURLSession, authentication:Phoenix.Authentication, configuration:Phoenix.Configuration) {
            self.sessionManager = session
            self.authentication = authentication
            
            super.init()
            
            // If the request cannot be build we should exit.
            // This may need to raise some sort of warning to the developer (currently
            // only due to misconfigured properties - which should be enforced by Phoenix initializer).
            guard let request = NSURLRequest.phx_requestForAuthentication(authentication, configuration: configuration),
                preparedRequest = request.phx_preparePhoenixRequest(withAuthentication: authentication) else {
                return nil
            }
            
            self.input = preparedRequest
        }
        
        override func main() {
            assert(self.input != nil, "Can't execute an Authentication operation with no request.")
            
//          Exponential backoff. Deactivated to avoid locking an account. See `
//            let backoff = exponentialBackoff()
//            backoff(block:requestAuthentication)
            
            if !requestAuthentication() {
                cancel()
            }
        }
        
        func requestAuthentication() -> Bool {
            guard let request = input else {
                assert(false, "Can't execute an Authentication operation with no request.")
            }

            let (data, response, error) = sessionManager.phx_executeSynchronousDataTaskWithRequest(request)
            
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
        
    }
}
