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
    
    init(userId: Int, user: Intelligence.User? = nil, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: @escaping IntelligenceAPICallback) {
        self.userId = userId
        super.init(user: user, oauth: oauth, configuration: configuration, network: network, callback: callback)
    }
    
    override func main() {
        super.main()
        
        let request = URLRequest.int_URLRequestForGetUser(userId: userId, oauth: oauth!, configuration: configuration!, network: network!)
        
        sharedIntelligenceLogger.logger?.debug(request.description)

        output = session?.int_executeSynchronousDataTask(with: request)
        parse()
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(userId:userId, user: user, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}
