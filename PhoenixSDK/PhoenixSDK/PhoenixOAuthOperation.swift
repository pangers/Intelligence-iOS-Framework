//
//  PhoenixOAuthOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

typealias PhoenixOAuthResponse = (data: NSData?, response: NSURLResponse?, error: NSError?)

private let AccessDeniedErrorCode = "access_denied"

internal class PhoenixOAuthOperation: TSDOperation<PhoenixOAuthResponse, PhoenixOAuthResponse> {
    var shouldBreak: Bool = false
    
    // Contextually relevant information to pass between operations.
    var oauth: PhoenixOAuthProtocol?
    var configuration: Phoenix.Configuration?
    var network: Network?
    var session: NSURLSession! {
        return network!.sessionManager
    }
    
    // MARK: Output Helpers
    
    func handleError(domain: String, code: Int) -> Bool {
        if let error = outputErrorCode() {
            if error == AccessDeniedErrorCode {
                output?.error = NSError(domain: RequestError.domain, code: RequestError.AccessDeniedError.rawValue, userInfo: nil)
                return true
            }
            output?.error = NSError(domain: domain, code: code, userInfo: nil)
            return true
        }
        if output?.error != nil {
            output?.error = NSError(domain: domain, code: code, userInfo: nil)
            return true
        }
        return false
    }
    
    /// Returns error code if response contains some sort of server error but request was 200.
    func outputErrorCode() -> String? {
        guard let error = self.output?.data?.phx_jsonDictionary?["error"] as? String else {
            return nil
        }
        print("Server Error:", error, self.output?.data?.phx_jsonDictionary?["error_description"] ?? "")
        return error
    }
    
    /// Returns all dictionaries in the 'Data' array of the output.
    func outputArray() -> JSONDictionaryArray? {
        guard let dataArray = self.output?.data?.phx_jsonDictionary?["Data"] as? JSONDictionaryArray else {
            return nil
        }
        return dataArray
    }
    
    /// Most API methods can use this helper to extract the first dictionary in the 'Data' array of output.
    func outputDictionary() -> JSONDictionary? {
        guard let dataDictionary = outputArray()?.first else {
            return nil
        }
        return dataDictionary
    }
}
