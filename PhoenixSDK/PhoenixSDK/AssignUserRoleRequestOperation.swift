//
//  AssignUserRoleRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for User Role Assignment.
internal final class AssignUserRoleRequestOperation : UserRequestOperation {
    
    override func main() {
        super.main()
        assert(sentUser != nil)
        let request = NSURLRequest.phx_URLRequestForUserRoleAssignment(sentUser!, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.phx_executeSynchronousDataTaskWithRequest(request)
        
        if handleError() {
            return
        }
        
        guard let _ = outputArrayFirstDictionary() else {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
        // For assign, we don't actually receive a user, lets return the user we sent so this method adheres to the Identity-type requests.
        user = sentUser
    }
    
}