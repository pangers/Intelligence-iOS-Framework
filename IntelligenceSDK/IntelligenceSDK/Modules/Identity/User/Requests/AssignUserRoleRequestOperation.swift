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
    
    init(roleId: Int, user: Intelligence.User?, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: @escaping IntelligenceAPICallback) {
        self.roleId = roleId
        super.init(user: user, oauth: oauth, configuration: configuration, network: network, callback: callback)
    }
    
    override func main() {
        super.main()
        assert(sentUser != nil)
        
        let request = URLRequest.int_URLRequestForUserRoleAssignment(roleId: roleId, user: sentUser!, oauth: oauth!, configuration: configuration!, network: network!)
        
        sharedIntelligenceLogger.logger?.debug(request.description)

        output = network?.sessionManager?.int_executeSynchronousDataTask(with: request)
        
        if handleError() {
            return
        }
        
        guard let _ = outputArrayFirstDictionary() else {
            output?.error = NSError(code: RequestError.parseError.rawValue)
            
            let str = String(format: "Parse error -- %@", (self.session?.description)!)
            sharedIntelligenceLogger.logger?.error(str)
            
            return
        }
        // For assign, we don't actually receive a user, lets return the user we sent so this method adheres to the Identity-type requests.
        user = sentUser
        
        if let httpResponse = output?.response as? HTTPURLResponse {
            sharedIntelligenceLogger.logger?.debug(httpResponse.description)
        }
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(roleId: roleId, user: sentUser, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}
