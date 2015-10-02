//
//  PhoenixOAuthRefreshOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

// Status Codes:
// 401: token_expired (EXPIRE token, need to refresh)
// 403: invalid_token (INVALID access, cannot use this method)

internal class PhoenixOAuthRefreshOperation : PhoenixOAuthOperation {
    
    override func main() {
        assert(oauth != nil && phoenix != nil)
        if (oauth?.refreshToken == nil) {
            print("Refresh Token Skipped")
            return
        }
        let request = NSURLRequest.phx_URLRequestForRefresh(oauth!, phoenix: phoenix!)
        output = session.phx_executeSynchronousDataTaskWithRequest(request)
        
        // Assumption: 200 status code means our token is valid, otherwise invalid.
        guard let httpResponse = output?.response as? NSHTTPURLResponse
            where httpResponse.statusCode == 200 &&
                oauth?.updateWithResponse(output?.data?.phx_jsonDictionary) == true else {
                    print("Refresh Token Failed \(output?.error)")
            return
        }
        self.shouldBreak = true
        print("Refresh Token Passed")
    }
    
}