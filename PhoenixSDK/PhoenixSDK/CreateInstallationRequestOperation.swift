//
//  CreateUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Create Installation API.
internal final class CreateInstallationRequestOperation : PhoenixNetworkRequestOperation {
    
    /// Installation object to retrieve information from.
    let installation: Phoenix.Installation
    
    /// Callback to trigger when operation completes.
    let callback: PhoenixInstallationCallback?
    
    /// Create new operation for Create Installation API.
    /// - parameter session:        NSURLSession to use.
    /// - parameter installation:   Installation object to retrieve information from.
    /// - parameter authentication: Authentication class required for super class.
    /// - parameter callback:       Callback to trigger when operation completes.
    /// - returns: A new CreateInstallationRequestOperation instance.
    init(session: NSURLSession, installation: Phoenix.Installation, authentication:Phoenix.Authentication, callback: PhoenixInstallationCallback?) {
        self.installation = installation
        self.callback = callback
        let request = NSURLRequest.phx_URLRequestForCreateInstallation(installation)
        super.init(withSession: session, request: request, authentication: authentication)
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        
        defer {
            callback?(installation: installation, error: error)
        }
        
        if error != nil {
            error = NSError(domain: RequestError.domain, code: RequestError.RequestFailedError.rawValue, userInfo: nil)
            return
        }
        
        guard let jsonData = getFirstDataDictionary()
            where installation.updateWithJSON(jsonData) == true else {
            error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
    }
}