//
//  AnalyticsRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// NSOperation that handles sending analytics.
internal final class AnalyticsRequestOperation: PhoenixOAuthOperation {
    
    private let eventsJSON: JSONDictionaryArray
    
    init(json: JSONDictionaryArray, oauth: PhoenixOAuth, phoenix: Phoenix) {
        self.eventsJSON = json
        super.init()
        self.oauth = oauth
        self.phoenix = phoenix
    }
    
    override func main() {
        assert(phoenix != nil && oauth != nil)
        
        let request = NSURLRequest.phx_URLRequestForAnalytics(eventsJSON, oauth: oauth!, phoenix: phoenix!)
        output = phoenix!.network.sessionManager.phx_executeSynchronousDataTaskWithRequest(request)
        if output?.error != nil || self.outputErrorCode() != nil {
            output?.error = NSError(domain: AnalyticsError.domain, code: AnalyticsError.SendAnalyticsError.rawValue, userInfo: nil)
            return
        }
        if outputArray()?.count != eventsJSON.count {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
    }
    
}