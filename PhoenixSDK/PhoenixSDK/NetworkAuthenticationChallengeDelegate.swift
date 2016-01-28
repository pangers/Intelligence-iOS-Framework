//
//  NetworkAuthenticationChallengeDelegate.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 26/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

internal class NetworkAuthenticationChallengeDelegate : NSObject, NSURLSessionDelegate {
    let configuration: Phoenix.Configuration
    
    init(configuration: Phoenix.Configuration) {
        self.configuration = configuration
    }
    
    @objc func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        // Trust the server
        // This needs to be done as the server certifcate does not cover the current url format
        // [module].api.[enviroment].phoenixplatform.[regionalDomain]
        completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
}