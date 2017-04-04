//
//  IntelligenceOAuthValidateOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal class IntelligenceOAuthValidateOperation : IntelligenceOAuthOperation {
    
    override func main() {
        super.main()
        assert(oauth != nil && network != nil && configuration != nil)
        if (oauth?.accessToken == nil) {
            print("\(oauth!.tokenType) Validate Token Skipped")
            return
        }
        let request = URLRequest.int_URLRequestForValidate(oauth: oauth!, configuration: configuration!, network: network!)
        sharedIntelligenceLogger.log(message: request.description);

        output = session?.int_executeSynchronousDataTask(with: request)
        
        if handleError() {
            print("\(oauth!.tokenType) Validate Failed \(output?.error)")
            return
        }
        
        // Assumption: 200 status code means our token is valid, otherwise invalid.
        guard let httpResponse = output?.response as? HTTPURLResponse, httpResponse.statusCode == HTTPStatusCode.success.rawValue &&
                output?.data?.int_jsonDictionary?[OAuthAccessTokenKey] != nil else
        {
            if output?.error == nil {
                output?.error = NSError(code: RequestError.parseError.rawValue)
            }
            
            print("\(oauth!.tokenType) Validate Token Failed \(output?.error)")

            let str = String(format: "Validate Token Failed -- %@", (output?.error?.description)!)
            sharedIntelligenceLogger.log(message: str);

            self.shouldBreak = true
            return
        }
        self.shouldBreak = true
        sharedIntelligenceLogger.log(message: "Validate Token Passed");

        print("\(oauth!.tokenType) Validate Token Passed")
    }
    
}
