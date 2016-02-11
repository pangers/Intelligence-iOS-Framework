//
//  GetUserRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Michael Lake on 03/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Get User API.
internal final class GetUserRequestOperation : UserRequestOperation {
    
    let userId: Int
    
    init(userId: Int, user: Intelligence.User? = nil, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: IntelligenceAPICallback) {
        self.userId = userId
        super.init(user: user, oauth: oauth, configuration: configuration, network: network, callback: callback)
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
