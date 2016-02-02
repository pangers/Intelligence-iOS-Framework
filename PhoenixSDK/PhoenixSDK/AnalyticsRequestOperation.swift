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
    
    private let InvalidRequestErrorCode = "invalid_request"
    
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
        
        // Swallowing the invalid request so that the events sent are cleared.
        // This error is not recoverable and we need to purge the data.
        if let httpResponse = output?.response as? NSHTTPURLResponse {
            if httpResponse.statusCode == HTTPStatusCode.BadRequest.rawValue && outputErrorCode() == InvalidRequestErrorCode {
                output?.error = NSError(domain: AnalyticsError.domain, code: AnalyticsError.OldEventsError.rawValue, userInfo: nil)
                return
            }
        }

        if handleError() {
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