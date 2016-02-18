//
//  IntelligenceOAuthLoginOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal class IntelligenceOAuthLoginOperation : IntelligenceOAuthOperation {
    
    override func main() {
        super.main()
        assert(oauth != nil && network != nil)

        if oauth?.password == nil {
            output?.error = NSError(code: RequestError.Unauthorized.rawValue)
            return
        }

        let request = NSURLRequest.int_URLRequestForLogin(oauth!, configuration: configuration!, network: network!)
        output = session.int_executeSynchronousDataTaskWithRequest(request)
        
        if handleError() {
            print("\(oauth!.tokenType) Login Failed \(output?.error)")
            return
        }
        
        // Assumption: 200 status code means our credentials are valid, otherwise invalid.
        guard let httpResponse = output?.response as? NSHTTPURLResponse
            where httpResponse.statusCode == HTTPStatusCode.Success.rawValue &&
                oauth?.updateWithResponse(output?.data?.int_jsonDictionary) == true else
        {
            if output?.error == nil {
                output?.error = NSError(code: RequestError.ParseError.rawValue)
            }
            print("\(oauth!.tokenType) Login Failed \(output?.error)")
            return
        }
        print("\(oauth!.tokenType) Login Passed")
    }
    
}