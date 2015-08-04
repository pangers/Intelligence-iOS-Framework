//
//  CreateUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class CreateUserRequestOperation : PhoenixNetworkRequestOperation {
    
    private(set) var createdUser:PhoenixUser?
    let configuration:PhoenixConfigurationProtocol
    
    
    /// Default initializer with all required parameters
    init(session:NSURLSession, user:PhoenixUser, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol) {
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: configuration)
        self.configuration = configuration
        super.init(withSession: session, withRequest: request, withAuthentication: authentication)
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        
        // Check for network errors
        if self.error != nil {
            self.error = NSError(domain: IdentityError.domain, code: IdentityError.UserCreationError.rawValue, userInfo: nil)
            return
        }
        
        // Try to pare the created user
        if let jsonResponse = self.output?.data?.phx_jsonDictionary,
            let jsonData = jsonResponse["Data"] as? JSONArray,
            let userData = jsonData.first as? JSONDictionary {
                // If all conditions succeed, parse the user.
                self.createdUser = Phoenix.User(withJSON: userData, withConfiguration:configuration)
        }
        
        // If the parse failed, return an error.
        if self.createdUser == nil {
            self.error = NSError(domain: IdentityError.domain, code: IdentityError.UserCreationError.rawValue, userInfo: nil)
        }
    }

}