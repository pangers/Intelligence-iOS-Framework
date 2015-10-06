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
            where httpResponse.statusCode == HTTPStatusCode.Success.rawValue &&
                output?.data?.phx_jsonDictionary?[OAuthAccessTokenKey] != nil else
        {
            if output?.error == nil {
                output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            }
            print("\(oauth!.tokenType) Validate Token Failed \(output?.error)")
            self.shouldBreak = true
            return
        }
        self.shouldBreak = true
        print("\(oauth!.tokenType) Validate Token Passed")
    }
    
}