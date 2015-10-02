//
//  PhoenixOAuthLoginOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal class PhoenixOAuthLoginOperation : PhoenixOAuthOperation {
    
    override func main() {
        assert(oauth != nil && network != nil)
        let request = NSURLRequest.phx_URLRequestForLogin(oauth!, configuration: configuration!, network: network!)
        output = session.phx_executeSynchronousDataTaskWithRequest(request)
        
        // Assumption: 200 status code means our credentials are valid, otherwise invalid.
        guard let httpResponse = output?.response as? NSHTTPURLResponse
            where httpResponse.statusCode == HTTPStatusCode.Success.rawValue &&
                oauth?.updateWithResponse(output?.data?.phx_jsonDictionary) == true else {
                    print("Login Failed \(output?.error)")
                    return
        }
        print("Login Passed")
    }
    
}