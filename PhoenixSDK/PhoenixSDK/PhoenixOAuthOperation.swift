//
//  PhoenixOAuthOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

typealias PhoenixOAuthResponse = (data: NSData?, response: NSURLResponse?, error: NSError?)

// Returned operation will be different than operation in some circumstances where tokens expire.
typealias PhoenixOAuthCallback = (returnedOperation: PhoenixOAuthOperation) -> ()

private let BodyData = "Data"
private let BodyErrorDescription = "error_description"
private let BodyError = "error"
private let OfflineErrorCode = -1009

internal class PhoenixOAuthOperation: TSDOperation<PhoenixOAuthResponse, PhoenixOAuthResponse> {
    var shouldBreak: Bool = false
    
    // Contextually relevant information to pass between operations.
    var callback: PhoenixOAuthCallback?
    var oauth: PhoenixOAuthProtocol?
    var configuration: Phoenix.Configuration?
    var network: Network?
    var session: NSURLSession! {
        return network!.sessionManager
    }
    
    // MARK: Output Helpers
    
    func complete() {
        callback?(returnedOperation: self)
    }
    
    func handleError() -> Bool {
        // This is NSURLSession's reponse code if we are offline
        if output?.error?.code == OfflineErrorCode {
            output?.error = NSError(code: RequestError.InternetOfflineError.rawValue)
            return true
        }
        
        if let httpResponse = output?.response as? NSHTTPURLResponse {
            if httpResponse.statusCode == HTTPStatusCode.Unauthorized.rawValue {
                output?.error = NSError(code: RequestError.Unauthorized.rawValue)
                
                let data = self.output?.data?.phx_jsonDictionary
                
                if let data = data {
                    let error = data[BodyError] as? String
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
                }
                
                return true
            }
            else if httpResponse.statusCode == HTTPStatusCode.Forbidden.rawValue {
                output?.error = NSError(code: RequestError.Forbidden.rawValue)
                return true
            }
            else if httpResponse.statusCode / 100 != 2 {
                output?.error = NSError(code: RequestError.UnhandledError.rawValue, httpStatusCode:httpResponse.statusCode)
                return true
            }
        }
        return false
    }
    
    /// Returns error if response contains an error in the data.
    func errorInData() -> String? {
        return self.output?.data?.phx_jsonDictionary?[BodyError] as? String
    }
    
    /// Returns all dictionaries in the 'Data' array of the output.
    func outputArray() -> JSONDictionaryArray? {
        guard let dataArray = self.output?.data?.phx_jsonDictionary?[BodyData] as? JSONDictionaryArray else {
            return nil
        }
        return dataArray
    }
    
    /// Most API methods can use this helper to extract the first dictionary in the 'Data' array of output.
    func outputArrayFirstDictionary() -> JSONDictionary? {
        guard let dataDictionary = outputArray()?.first else {
            return nil
        }
        return dataDictionary
    }
}
