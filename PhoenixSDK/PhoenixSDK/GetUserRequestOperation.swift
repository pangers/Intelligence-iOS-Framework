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
    
    let userId: Int
    
    required init(userId: Int, user: Phoenix.User? = nil, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixAPICallback) {
        self.userId = userId
        super.init(user: user, oauth: oauth, configuration: configuration, network: network, callback: callback)
    }

    required init(user: Phoenix.User?, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixAPICallback) {
        preconditionFailure("userId is not set")
    }
    
    override func main() {
        super.main()
        
        let request = NSURLRequest.phx_URLRequestForGetUser(userId, oauth: oauth!, configuration: configuration!, network: network!)
        output = session.phx_executeSynchronousDataTaskWithRequest(request)
        parse()
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init(userId:userId, user: user, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}
