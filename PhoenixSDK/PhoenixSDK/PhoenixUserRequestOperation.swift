//
//  PhoenixUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class PhoenixUserRequestOperation : PhoenixOAuthOperation, NSCopying {
    
    /// Once successful, this will contain the user provided by the backend.
    var user: Phoenix.User?
    
    let sentUser: Phoenix.User?
    
    /// Create new User request.
    required init(user: Phoenix.User? = nil, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network) {
        self.sentUser = user
        super.init()
        self.oauth = oauth
        self.configuration = configuration
        self.network = network
    }
    
    /// Parse.
    func parse(withErrorCode errorCode: Int) {
        if handleError(IdentityError.domain, code: errorCode) {
            return
        }
        
        guard let receivedUser = Phoenix.User(withJSON: self.outputDictionary(), configuration: configuration!) else {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
        user = receivedUser
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(user: sentUser, oauth: oauth!, configuration: configuration!, network: network!)
    }
    
}