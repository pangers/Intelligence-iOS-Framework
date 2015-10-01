//
//  GetUserMeRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Get Me API.
internal final class GetUserMeRequestOperation : PhoenixUserRequestOperation {
    
    override func main() {
        assert(phoenix!.developerLoggedIn, "GetMe can only be called explicitly by developers currently, and only on an account they have logged into.")
        let oauth = PhoenixOAuth(tokenType: .LoggedInUser)
        let request = NSURLRequest.phx_URLRequestForUserMe(oauth, phoenix: phoenix!)
        output = phoenix!.network.sessionManager.phx_executeSynchronousDataTaskWithRequest(request)
        parse(withErrorCode: IdentityError.UserUpdateError.rawValue)
    }

}