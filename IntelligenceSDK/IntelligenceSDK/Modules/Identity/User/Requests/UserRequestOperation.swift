//
//  UserRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Inheritors must ensure all relevent fields will be copied by copyWithZone(zone:), which must be overriden.
class UserRequestOperation : IntelligenceAPIOperation, NSCopying {
    
    /// Once successful, this will contain the user provided by the backend.
    var user: Intelligence.User?
    
    let sentUser: Intelligence.User?
    
    /// Initialize UserRequestOperation.
    /// - parameter user: The user to send during the operation.
    /// - parameter oauth: The oauth values to use for this operation.
    /// - parameter configuration: The configuration values to use for this operation.
    /// - parameter network: The network the operation will be queued on.
    /// - parameter callback: The callback called on completion of the operation.
    init(user: Intelligence.User? = nil, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: @escaping IntelligenceAPICallback) {
        self.sentUser = user
        super.init()
        self.callback = callback
        self.oauth = oauth
        self.configuration = configuration
        self.network = network
    }
    
    override func main() {
        super.main()
    }
    
    /// Parse.
    func parse() {
        if handleError() {
            return
        }
        
        guard let receivedUser = Intelligence.User(withJSON: outputArrayFirstDictionary(), configuration: configuration!) else {
            output?.error = NSError(code: RequestError.parseError.rawValue)
            let str = String(format: "Parse error -- %@", (self.session?.description)!)
            sharedIntelligenceLogger.logger?.error(str)
            return
        }
        user = receivedUser
        
        if let httpResponse = output?.response as? HTTPURLResponse {
            sharedIntelligenceLogger.logger?.debug(httpResponse.description)
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        preconditionFailure("copyWithZone(zone:) sould never be called on UserRequestOperation, it needs to be overridden")
    }
}
