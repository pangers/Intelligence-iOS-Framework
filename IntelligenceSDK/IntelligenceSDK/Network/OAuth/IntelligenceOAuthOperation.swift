//
//  IntelligenceOAuthOperation.swift
//  IntelligenceSDK
//
//  Created by Michael Lake on 04/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

private let BodyError = "error"
private let BodyErrorDescription = "error_description"

class IntelligenceOAuthOperation : IntelligenceAPIOperation {

    // This method should never call super otherwise we will get stuck in a 'OAuth' loop
    // due to the 'network?.getPipeline(forOAuth:...' call.
    override func handleUnauthorizedError() {
        let data = self.output?.data?.int_jsonDictionary
        
        if let data = data {
            let error = data[BodyError] as? String
            let errorDescription = data[BodyErrorDescription] as? String
            
            // We are reading the errorDescription and comparing it to plain text sentences
            // that have been defined. It is noted that this is not an ideal way to detect errors.
            // If the descriptions are changed on the server without updating the client then these
            // errors will not be detected.
            
            if error == "Authentication failed." {
                if errorDescription == "Credentials incorrect." {
                    output?.error = NSError(code: AuthenticationError.credentialError.rawValue)
                    
                    let str = String(format: "Credentials incorrect. -- %@", (output?.error?.description)!)
                    sharedIntelligenceLogger.log(message: str)
                }
                else if errorDescription == "Account disabled." {
                    output?.error = NSError(code: AuthenticationError.accountDisabledError.rawValue)
                    
                    let str = String(format: "Account disabled. -- %@", (output?.error?.description)!)
                    sharedIntelligenceLogger.log(message: str)
                }
                else if errorDescription == "Account locked." {
                    output?.error = NSError(code: AuthenticationError.accountLockedError.rawValue)
                    
                    let str = String(format: "Account locked. -- %@", (output?.error?.description)!)
                    sharedIntelligenceLogger.log(message: str)
                }
            }
            else if error == "Invalid token." {
                if errorDescription == "Token invalid or expired." {
                    output?.error = NSError(code: AuthenticationError.tokenInvalidOrExpired.rawValue)
                    
                    let str = String(format: "Token invalid or expired. -- %@", (output?.error?.description)!)
                    sharedIntelligenceLogger.log(message: str)
                }
            }
            else
            {
                output?.error = NSError(code: RequestError.unauthorized.rawValue)
                let str = String(format: "Parse error -- %@", (output?.error?.description)!)
                sharedIntelligenceLogger.log(message: str)
            }
        }
        else
        {
            output?.error = NSError(code: RequestError.unauthorized.rawValue)
            let str = String(format: "Parse error -- %@", (output?.error?.description)!)
            sharedIntelligenceLogger.log(message: str)
        }
    }
}
