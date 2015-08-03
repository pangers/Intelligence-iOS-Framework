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
    init(withSession session:NSURLSession, withUser user:PhoenixUser, withAuthentication authentication:Phoenix.Authentication) {
        super.init(withSession: session, withRequest: CreateUserRequestOperation.requestForUser(user), withAuthentication: authentication)
    }
    
    class func requestForUser(user:PhoenixUser) -> NSURLRequest {
        return NSURLRequest()
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        // self.error and output contain the error and output. Parse output into createdUser.
    }

}