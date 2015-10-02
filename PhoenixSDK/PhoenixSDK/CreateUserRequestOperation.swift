//
//  CreateUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Create User API.
internal final class CreateUserRequestOperation : PhoenixUserRequestOperation {
    
    override func main() {
        assert(sentUser != nil)
        let request = NSURLRequest.phx_URLRequestForUserCreation(sentUser!, phoenix: phoenix!)
        output = phoenix!.network.sessionManager.phx_executeSynchronousDataTaskWithRequest(request)
        parse(withErrorCode: IdentityError.UserCreationError.rawValue)
    }
    
}