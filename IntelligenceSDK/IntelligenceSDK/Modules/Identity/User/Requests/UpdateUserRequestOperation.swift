//
//  UpdateUserRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 07/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Update User API.
internal final class UpdateUserRequestOperation: UserRequestOperation {

    override func main() {
        super.main()
        assert(network!.oauthProvider.developerLoggedIn, "Update can only be called explicitly by developers currently, and only on an account they have logged into.")
        assert(sentUser != nil)
        let request = URLRequest.int_URLRequestForUserUpdate(user: sentUser!, oauth: oauth!, configuration: configuration!, network: network!)
        
        sharedIntelligenceLogger.logger?.debug(request.description)

        output = network?.sessionManager?.int_executeSynchronousDataTask(with: request)
        parse()
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(user: sentUser, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}
