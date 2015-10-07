//
//  AnalyticsRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// NSOperation that handles sending analytics.
internal final class AnalyticsRequestOperation: PhoenixOAuthOperation, NSCopying {
    
    private let eventsJSON: JSONDictionaryArray
    
    required init(json: JSONDictionaryArray, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixOAuthCallback) {
        self.eventsJSON = json
        super.init()
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        assert(network != nil && configuration != nil)
        let request = NSURLRequest.phx_URLRequestForAnalytics(eventsJSON, oauth: oauth!, configuration: configuration!, network: network!)
        output = session.phx_executeSynchronousDataTaskWithRequest(request)
        if handleError(AnalyticsError.domain, code: AnalyticsError.SendAnalyticsError.rawValue) {
            return
        }
        if outputArray()?.count != eventsJSON.count {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(json: eventsJSON, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
    }
    
}