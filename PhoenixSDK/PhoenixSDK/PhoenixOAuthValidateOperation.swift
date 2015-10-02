//
//  PhoenixOAuthOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal class PhoenixOAuthValidateOperation : PhoenixOAuthOperation {
    
    override func main() {
        assert(oauth != nil && network != nil && configuration != nil)
        if (oauth?.accessToken == nil) {
            print("Validate Token Skipped")
            return
        }
        let request = NSURLRequest.phx_URLRequestForValidate(oauth!, configuration: configuration!, network: network!)
        output = session.phx_executeSynchronousDataTaskWithRequest(request)
        
        // Assumption: 200 status code means our token is valid, otherwise invalid.
        guard let httpResponse = output?.response as? NSHTTPURLResponse
            where httpResponse.statusCode == 200 else {
                print("Validate Token Failed \(output?.error)")
            return
        }
        self.shouldBreak = true
        print("Validate Token Passed")
    }
    
}