//
//  UserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class UserRequestOperation : PhoenixOAuthOperation, NSCopying {
    
    /// Once successful, this will contain the user provided by the backend.
    var user: Phoenix.User?
    
    let sentUser: Phoenix.User?
    
    /// Create new User request.
    required init(user: Phoenix.User? = nil, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixOAuthCallback) {
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
        return self.dynamicType.init(user: sentUser, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
    }
    
}