//
//  CreateUserRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Create User API.
internal final class CreateUserRequestOperation : UserRequestOperation {
    
    override func main() {
        super.main()
        assert(sentUser != nil)
        let request = NSURLRequest.int_URLRequestForUserCreation(sentUser!, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.int_executeSynchronousDataTaskWithRequest(request)
        parse()
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init(user: sentUser, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}
