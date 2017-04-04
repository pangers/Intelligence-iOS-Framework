//
//  IntelligenceOAuthRefreshOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal class IntelligenceOAuthRefreshOperation : IntelligenceOAuthOperation {
    
    override func main() {
        super.main()
        assert(oauth != nil && network != nil)
        if (oauth?.refreshToken == nil) {
            print("\(oauth!.tokenType) Refresh Token Skipped")
            
            let str = String(format: "Refresh Token Skipped")
            sharedIntelligenceLogger.log(message: str)
            
            return
        }
        let request = URLRequest.int_URLRequestForRefresh(oauth: oauth!, configuration: configuration!, network: network!)
        
        sharedIntelligenceLogger.log(message: request.description);

        output = session?.int_executeSynchronousDataTask(with: request)
        
        if handleError() {
            print("\(oauth!.tokenType) Refresh Token Failed \(output?.error)")
            
            let str = String(format: "Refresh Token Failed")
            sharedIntelligenceLogger.log(message: str)
            return
        }
        
        // Assumption: 200 status code means our token is valid, otherwise invalid.
        guard let httpResponse = output?.response as? HTTPURLResponse, httpResponse.statusCode == HTTPStatusCode.success.rawValue &&
                oauth?.updateWithResponse(response: output?.data?.int_jsonDictionary) == true else
        {
            if output?.error == nil {
                output?.error = NSError(code: RequestError.parseError.rawValue)
            }
            print("\(oauth!.tokenType) Refresh Token Failed \(output?.error)")
            
            let str = String(format: "Refresh Token Failed -- %@", (self.session?.description)!)
            sharedIntelligenceLogger.log(message: str)
            
            self.shouldBreak = true
            return
        }
        self.shouldBreak = true
        print("\(oauth!.tokenType) Refresh Token Passed")
        sharedIntelligenceLogger.log(message: httpResponse.description)

    }
    
    override func handleUnauthorizedError() {
        if self.oauth?.tokenType == .loggedInUser {
            // Token is no longer valid and cannot be refreshed without user input.
            // Do not try again. Alert developer.
            network?.delegate?.userLoginRequired()
        }
        
        super.handleUnauthorizedError()
    }
}
