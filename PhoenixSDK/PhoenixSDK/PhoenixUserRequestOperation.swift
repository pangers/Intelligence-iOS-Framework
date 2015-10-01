//
//  PhoenixUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class PhoenixUserRequestOperation : PhoenixOAuthOperation {
    
    /// Once successful, this will contain the user provided by the backend.
    var user: Phoenix.User?
    
    let sentUser: Phoenix.User?
    
    /// Create new User request.
    init(user: Phoenix.User? = nil, phoenix: Phoenix) {
        self.sentUser = user
        super.init()
        self.phoenix = phoenix
    }
    
    /// Parse.
    func parse(withErrorCode errorCode: Int) {
        if handleError(IdentityError.domain, code: errorCode) {
            return
        }
        
        guard let receivedUser = Phoenix.User(withJSON: self.outputDictionary(), configuration: phoenix!.configuration) else {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
        user = receivedUser
    }

}