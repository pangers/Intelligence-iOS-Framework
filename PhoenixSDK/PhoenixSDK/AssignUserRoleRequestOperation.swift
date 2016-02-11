//
//  AssignUserRoleRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for User Role Assignment.
internal final class AssignUserRoleRequestOperation : UserRequestOperation {
    
    let roleId: Int
    
    init(roleId: Int, user: Intelligence.User?, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: IntelligenceAPICallback) {
        self.roleId = roleId
        super.init(user: user, oauth: oauth, configuration: configuration, network: network, callback: callback)
    }
    
    override func main() {
        super.main()
        assert(sentUser != nil)
        
        let request = NSURLRequest.phx_URLRequestForUserRoleAssignment(roleId, user: sentUser!, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.phx_executeSynchronousDataTaskWithRequest(request)
        
        if handleError() {
            return
        }
        
        guard let _ = outputArrayFirstDictionary() else {
            output?.error = NSError(code: RequestError.ParseError.rawValue)
            return
        }
        // For assign, we don't actually receive a user, lets return the user we sent so this method adheres to the Identity-type requests.
        user = sentUser
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init(roleId: roleId, user: sentUser, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}