//
//  PhoenixUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class PhoenixUserRequestOperation : PhoenixNetworkRequestOperation {
    var user: Phoenix.User?
    var configuration: PhoenixConfigurationProtocol?
    var errorCode: Int = 0
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        if error != nil {
            error = NSError(domain: IdentityError.domain, code: errorCode, userInfo: nil)
            return
        }
        guard let userData = (self.output?.data?.phx_jsonDictionary?["Data"] as? JSONArray)?.first as? JSONDictionary, configuration = configuration else {
            return
        }
        // If all conditions succeed, parse the user.
        user = Phoenix.User(withJSON: userData, withConfiguration: configuration)
        if user == nil {
            error = NSError(domain: IdentityError.domain, code: errorCode, userInfo: nil)
        }
    }
}