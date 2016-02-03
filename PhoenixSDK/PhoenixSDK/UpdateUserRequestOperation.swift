//
//  UpdateUserRequestOperation.swift
//  PhoenixSDK
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
        let request = NSURLRequest.phx_URLRequestForUserUpdate(sentUser!, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.phx_executeSynchronousDataTaskWithRequest(request)
        parse()
    }

}
