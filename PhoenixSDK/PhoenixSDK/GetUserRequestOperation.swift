//
//  GetUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 03/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Get User API.
internal final class GetUserRequestOperation : UserRequestOperation {
    
    let userId: Int?
    
    required init(userId: Int, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixAPICallback) {
        self.userId = userId
        super.init(oauth: oauth, configuration: configuration, network: network, callback: callback)
    }

    required init(user: Phoenix.User?, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixAPICallback) {
        self.userId = user?.userId
        super.init(oauth: oauth, configuration: configuration, network: network, callback: callback)
    }
    
    override func main() {
        super.main()
        
        guard let userId = userId else {
            output?.error = NSError(code: IdentityError.InvalidUserError.rawValue)
            return
        }
        
        let request = NSURLRequest.phx_URLRequestForGetUser(userId, oauth: oauth!, configuration: configuration!, network: network!)
        output = session.phx_executeSynchronousDataTaskWithRequest(request)
        parse()
    }
    
}
