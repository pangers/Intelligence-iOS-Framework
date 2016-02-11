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
        let request = NSURLRequest.phx_URLRequestForUserMe(oauth!, configuration: configuration!, network: network!)
        output = session.phx_executeSynchronousDataTaskWithRequest(request)
        parse()
    }

}