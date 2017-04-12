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

        // If the password is unset and the token type is not 'Application'
        // (which doesn't require a password for Login). Lets raise an error.
        if oauth?.tokenType != .application && oauth?.password == nil {
            // We need an output object, so let's make a dummy one
            output = (data: nil, response: nil, error: nil)
            output?.error = NSError(code: RequestError.unauthorized.rawValue)
            return
        }

        let request = URLRequest.int_URLRequestForLogin(oauth: oauth!, configuration: configuration!, network: network!)

        // sharedIntelligenceLogger.log(message: request.description);
        sharedIntelligenceLogger.logger?.debug(request.description)

        output = session?.int_executeSynchronousDataTask(with: request)
        
        if handleError() {
//            print("\(oauth!.tokenType) Login Failed \(output?.error)")
            sharedIntelligenceLogger.logger?.error(self.output?.error?.description)
            return
        }
        
        // Assumption: 200 status code means our credentials are valid, otherwise invalid.
        guard let httpResponse = output?.response as? HTTPURLResponse, httpResponse.statusCode == HTTPStatusCode.success.rawValue &&
                oauth?.updateWithResponse(response: output?.data?.int_jsonDictionary) == true else
        {
            if output?.error == nil {
                output?.error = NSError(code: RequestError.parseError.rawValue)
            }
            sharedIntelligenceLogger.logger?.error(self.output?.error?.description)
//            print("\(oauth!.tokenType) Login Failed \(output?.error)")
            return
        }
        sharedIntelligenceLogger.logger?.debug(httpResponse.debugInfo)
        print("\(oauth!.tokenType) Login Passed")
    }
    
}
