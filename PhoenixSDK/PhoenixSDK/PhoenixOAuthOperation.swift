//
//  PhoenixOAuthOperation.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 04/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

private let BodyError = "error"
private let BodyErrorDescription = "error_description"

class PhoenixOAuthOperation : PhoenixAPIOperation {
    override func handleUnauthroizedError() {
        let data = self.output?.data?.phx_jsonDictionary
        
        if let data = data {
            let error = data[""] as? String
            let errorDescription = data[BodyErrorDescription] as? String
            
            // We are reading the errorDescription and comparing it to plain text sentences
            // that have been defined. It is noted that this is not an ideal way to detect errors.
            // If the descriptions are changed on the server without updating the client then these
            // errors will not be detected.
            
            if error == "Authentication failed." {
                if errorDescription == "Credentials incorrect." {
                    output?.error = NSError(code: AuthenticationError.CredentialError.rawValue)
                }
                else if errorDescription == "Account disabled." {
                    output?.error = NSError(code: AuthenticationError.AccountDisabledError.rawValue)
                }
                else if errorDescription == "Account locked." {
                    output?.error = NSError(code: AuthenticationError.AccountLockedError.rawValue)
                }
            }
            else if error == "Invalid token." {
                if errorDescription == "Token invalid or expired." {
                    output?.error = NSError(code: AuthenticationError.TokenInvalidOrExpired.rawValue)
                }
            }
            else
            {
                output?.error = NSError(code: RequestError.Unauthorized.rawValue)
            }
        }
        else
        {
            output?.error = NSError(code: RequestError.Unauthorized.rawValue)
        }
    }
}
