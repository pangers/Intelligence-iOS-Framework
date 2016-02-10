//
//  UserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Inheritors must ensure all relevent fields will be copied by copyWithZone(zone:), which may require an override.
class UserRequestOperation : PhoenixAPIOperation, NSCopying {
    
    /// Once successful, this will contain the user provided by the backend.
    var user: Phoenix.User?
    
    let sentUser: Phoenix.User?
    
    init(user: Phoenix.User? = nil) {
        self.sentUser = user
        super.init()
    }
    
    /// Create new User request.
    init(user: Phoenix.User? = nil, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixAPICallback) {
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
        
        guard let receivedUser = Phoenix.User(withJSON: outputArrayFirstDictionary(), configuration: configuration!) else {
            output?.error = NSError(code: RequestError.ParseError.rawValue)
            return
        }
        user = receivedUser
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = UserRequestOperation(user: sentUser)
        copy.callback = callback
        copy.oauth = oauth
        copy.configuration = configuration
        copy.network = network
        
        return copy
    }
    
}