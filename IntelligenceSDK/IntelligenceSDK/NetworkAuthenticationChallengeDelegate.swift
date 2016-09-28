//
//  NetworkAuthenticationChallengeDelegate.swift
//  IntelligenceSDK
//
//  Created by Michael Lake on 26/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

internal class NetworkAuthenticationChallengeDelegate : NSObject, NSURLSessionDelegate {
    let configuration: Intelligence.Configuration
    
    init(configuration: Intelligence.Configuration) {
        self.configuration = configuration
    }
    
    @objc func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod != NSURLAuthenticationMethodServerTrust {
            completionHandler(.PerformDefaultHandling, nil)
            return
        }
        
        switch self.configuration.certificateTrustPolicy {
            case .Valid:
                // Use the default handling
                completionHandler(.PerformDefaultHandling, nil)
            case .AnyNonProduction where self.configuration.environment == .Production:
                // Use the default handling
                completionHandler(.PerformDefaultHandling, nil)
            case .AnyNonProduction:
                // Trust the server
                completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
            case .Any:
                // Trust the server
                completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
        }
    }
}