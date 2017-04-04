//
//  RevokeUserRoleRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Michael Lake on 05/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for User Role Revoke.
internal final class RevokeUserRoleRequestOperation : UserRequestOperation {
    
    let roleId: Int
    
    init(roleId: Int, user: Intelligence.User?, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: @escaping IntelligenceAPICallback) {
        self.roleId = roleId
        super.init(user: user, oauth: oauth, configuration: configuration, network: network, callback: callback)
    }
    
    override func main() {
        super.main()
        assert(sentUser != nil)
        
        let request = URLRequest.int_URLRequestForUserRoleRevoke(roleId: roleId, user: sentUser!, oauth: oauth!, configuration: configuration!, network: network!)
        
        sharedIntelligenceLogger.log(message: request.description);

        output = network?.sessionManager?.int_executeSynchronousDataTask(with: request)
        
        if handleError() {
            return
        }
        
        guard let _ = outputArrayFirstDictionary() else {
            output?.error = NSError(code: RequestError.parseError.rawValue)
            
            let str = String(format: "Parse error -- %@", (self.session?.description)!)
            sharedIntelligenceLogger.log(message: str)
            
            return
        }
        
        // For revoke, we don't actually receive a user, lets return the user we sent so this method adheres to the Identity-type requests.
        user = sentUser
        
        if let httpResponse = output?.response as? HTTPURLResponse {
            sharedIntelligenceLogger.log(message: httpResponse.description);
        }
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(roleId: roleId, user: sentUser, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}
