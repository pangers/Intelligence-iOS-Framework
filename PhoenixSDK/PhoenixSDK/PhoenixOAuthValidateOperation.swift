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
            print("\(oauth!.tokenType) Validate Token Skipped")
            return
        }
        let request = NSURLRequest.phx_URLRequestForValidate(oauth!, configuration: configuration!, network: network!)
        output = session.phx_executeSynchronousDataTaskWithRequest(request)
        
        if handleError(IdentityError.domain, code: IdentityError.LoginFailed.rawValue) {
            print("\(oauth!.tokenType) Validate Failed \(output?.error)")
            return
        }
        
        // Assumption: 200 status code means our token is valid, otherwise invalid.
        guard let httpResponse = output?.response as? NSHTTPURLResponse
            where httpResponse.statusCode == HTTPStatusCode.Success.rawValue else {
                print("\(oauth!.tokenType) Validate Token Failed \(output?.error)")
            return
        }
        self.shouldBreak = true
        print("\(oauth!.tokenType) Validate Token Passed")
    }
    
}