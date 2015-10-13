//
//  PhoenixOAuthRefreshOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal class PhoenixOAuthRefreshOperation : PhoenixOAuthOperation {
    
    override func main() {
        super.main()
        assert(oauth != nil && network != nil)
        if (oauth?.refreshToken == nil) {
            print("\(oauth!.tokenType) Refresh Token Skipped")
            return
        }
        let request = NSURLRequest.phx_URLRequestForRefresh(oauth!, configuration: configuration!, network: network!)
        output = session.phx_executeSynchronousDataTaskWithRequest(request)
        
        if handleError(IdentityError.domain, code: IdentityError.LoginFailed.rawValue) {
            print("\(oauth!.tokenType) Refresh Token Failed \(output?.error)")
            return
        }
        
        // Assumption: 200 status code means our token is valid, otherwise invalid.
        guard let httpResponse = output?.response as? NSHTTPURLResponse
            where httpResponse.statusCode == HTTPStatusCode.Success.rawValue &&
                oauth?.updateWithResponse(output?.data?.phx_jsonDictionary) == true else
        {
            if output?.error == nil {
                output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            }
            print("\(oauth!.tokenType) Refresh Token Failed \(output?.error)")
            self.shouldBreak = true
            return
        }
        self.shouldBreak = true
        print("\(oauth!.tokenType) Refresh Token Passed")
    }
    
}