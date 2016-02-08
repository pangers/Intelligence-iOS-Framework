//
//  RevokeUserRoleRequestOperation.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 05/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for User Role Revoke.
internal final class RevokeUserRoleRequestOperation : UserRequestOperation {
    
    let roleId: Int?
    
    init(roleId: Int, user: Phoenix.User?, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixAPICallback) {
        self.roleId = roleId
        super.init(user: user, oauth: oauth, configuration: configuration, network: network, callback: callback)
    }

    required init(user: Phoenix.User?, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixAPICallback) {
        self.roleId = nil
        super.init(user: user, oauth: oauth, configuration: configuration, network: network, callback: callback)
    }
    
    override func main() {
        super.main()
        assert(sentUser != nil)
        
        guard let roleId = roleId else {
            return
        }
        
        let request = NSURLRequest.phx_URLRequestForUserRoleRevoke(roleId, user: sentUser!, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.phx_executeSynchronousDataTaskWithRequest(request)
        
        if handleError() {
            return
        }
        
        guard let _ = outputArrayFirstDictionary() else {
            output?.error = NSError(code: RequestError.ParseError.rawValue)
            return
        }
        
        // For revoke, we don't actually receive a user, lets return the user we sent so this method adheres to the Identity-type requests.
        user = sentUser
    }
    
}
