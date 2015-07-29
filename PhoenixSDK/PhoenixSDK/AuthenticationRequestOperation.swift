//
//  AuthenticationRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

extension PhoenixNetworkRequestOperation {

    /// Default initializer with all required parameters
    class func authenticationRequestOperation(withSession session:NSURLSession,
        withAuthentication authentication:Phoenix.Authentication?, withConfiguration configuration:Phoenix.Configuration)
        -> PhoenixNetworkRequestOperation? {
            
        // If the request cannot be build we should exit.
        // This may need to raise some sort of warning to the developer (currently
        // only due to misconfigured properties - which should be enforced by Phoenix initializer).
        guard let request = NSURLRequest.phx_requestForAuthentication(authentication, configuration: configuration) else {
            return nil
        }
        
        return PhoenixNetworkRequestOperation(withSession:session, withRequest:request, withAuthentication:authentication)
    }

}