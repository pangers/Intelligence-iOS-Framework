//
//  CreateUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation to wrap the create user request.
internal final class UpdateInstallationRequestOperation : PhoenixNetworkRequestOperation {

    let installation: Phoenix.Installation
    
    let callback: PhoenixInstallationCallback?
    
    /// Default initializer with all required parameters
    init(session:NSURLSession, installation: Phoenix.Installation, authentication:Phoenix.Authentication, callback: PhoenixInstallationCallback?) {
        self.installation = installation
        self.callback = callback
        let request = NSURLRequest.phx_httpURLRequestForCreateInstallation(installation)
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
        
        guard let data = self.output?.data,
            jsonDataArray = (data.phx_jsonDictionary?["Data"] as? JSONDictionaryArray),
            jsonData = jsonDataArray.first else {
            return
        }
        
        // Attempt to update stored values
        if !installation.updateWithJSON(jsonData) {
            error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
        }
    }
}