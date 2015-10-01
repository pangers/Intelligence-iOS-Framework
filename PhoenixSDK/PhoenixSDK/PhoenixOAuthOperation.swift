//
//  PhoenixOAuthOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

typealias PhoenixOAuthResponse = (data: NSData?, response: NSURLResponse?, error: NSError?)

internal class PhoenixOAuthOperation: TSDOperation<PhoenixOAuthResponse, PhoenixOAuthResponse> {
    var shouldBreak: Bool = false
    
    // Contextually relevant information to pass between operations.
    var oauth: PhoenixOAuth?
    var phoenix: Phoenix?
    var session: NSURLSession! {
        return phoenix!.network.sessionManager
    }
    
    // MARK: Output Helpers
    
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
