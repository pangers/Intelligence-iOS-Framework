//
//  GetUserMeRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Get Me API.
internal final class GetUserMeRequestOperation : UserRequestOperation {
    
    override func main() {
        super.main()
        assert(oauth?.tokenType != .Application)
        let request = URLRequest.int_URLRequestForUserMe(oauth: oauth!, configuration: configuration!, network: network!)
        output = session?.int_executeSynchronousDataTask(with: request)
        parse()
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(user: sentUser, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}
