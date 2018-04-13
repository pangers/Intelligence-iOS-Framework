//
//  CreateUserRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Create User API.
internal final class CreateUserRequestOperation: UserRequestOperation {

    override func main() {
        super.main()
        assert(sentUser != nil)
        let request = URLRequest.int_URLRequestForUserCreation(user: sentUser!, oauth: oauth!, configuration: configuration!, network: network!)

        sharedIntelligenceLogger.logger?.debug(request.description)

        output = network!.sessionManager!.int_executeSynchronousDataTask(with: request)
        parse()
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(user: sentUser, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)

        return copy
    }
}
