//
//  NetworkAuthenticationChallengeDelegate.swift
//  IntelligenceSDK
//
//  Created by Michael Lake on 26/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

internal class NetworkAuthenticationChallengeDelegate : NSObject, URLSessionDelegate {
    let configuration: Intelligence.Configuration
    
    init(configuration: Intelligence.Configuration) {
        self.configuration = configuration
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod != NSURLAuthenticationMethodServerTrust {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        switch self.configuration.certificateTrustPolicy {
        case .valid:
            // Use the default handling
            completionHandler(.performDefaultHandling, nil)
        case .anyNonProduction where self.configuration.environment == .production:
            // Use the default handling
            completionHandler(.performDefaultHandling, nil)
        case .anyNonProduction:
            // Trust the server
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        case .any:
            // Trust the server
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
}
