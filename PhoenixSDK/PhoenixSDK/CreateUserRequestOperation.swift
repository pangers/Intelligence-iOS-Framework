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
    
    /// Default initializer with all required parameters
    init(session:NSURLSession, user:PhoenixUser, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol) {
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: configuration)
        super.init(withSession: session, withRequest: request, withAuthentication: authentication)
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        
        // self.error and output contain the error and output. Parse output into createdUser.
        print(self.output)
        
    }

}