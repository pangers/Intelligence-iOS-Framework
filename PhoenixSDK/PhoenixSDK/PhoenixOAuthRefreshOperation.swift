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
        assert(oauth != nil && network != nil)
        if (oauth?.refreshToken == nil) {
            print("\(oauth!.tokenType) Refresh Token Skipped")
            return
        }
        let request = NSURLRequest.phx_URLRequestForRefresh(oauth!, configuration: configuration!, network: network!)
        output = session.phx_executeSynchronousDataTaskWithRequest(request)
        
        // Assumption: 200 status code means our token is valid, otherwise invalid.
        guard let httpResponse = output?.response as? NSHTTPURLResponse
            where httpResponse.statusCode == HTTPStatusCode.Success.rawValue &&
                oauth?.updateWithResponse(output?.data?.phx_jsonDictionary) == true else {
                    print("\(oauth!.tokenType) Refresh Token Failed \(output?.error)")
            return
        }
        self.shouldBreak = true
        print("\(oauth!.tokenType) Refresh Token Passed")
    }
    
}