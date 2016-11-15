//
//  AnalyticsRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// NSOperation that handles sending analytics.
/// Inheritors must ensure all relevent fields will be copied by copyWithZone(zone:), which may require an override.
internal final class AnalyticsRequestOperation: IntelligenceAPIOperation, NSCopying {
    
    private let eventsJSON: JSONDictionaryArray
    
    private let InvalidRequestErrorCode = "invalid_request"
    
    required init(json: JSONDictionaryArray, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: IntelligenceAPICallback) {
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
        let request = NSURLRequest.int_URLRequestForAnalytics(eventsJSON, oauth: oauth!, configuration: configuration!, network: network!)
        output = session.int_executeSynchronousDataTaskWithRequest(request)
        
        // Swallowing the invalid request so that the events sent are cleared.
        // This error is not recoverable and we need to purge the data.
        if let httpResponse = output?.response as? NSHTTPURLResponse {
            if httpResponse.statusCode == HTTPStatusCode.BadRequest.rawValue && errorInData() == InvalidRequestErrorCode {
                output?.error = NSError(code: AnalyticsError.OldEventsError.rawValue)
                return
            }
        }

        if handleError() {
            return
        }
        
        if outputArray()?.count != eventsJSON.count {
            output?.error = NSError(code: RequestError.ParseError.rawValue)
            return
        }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init(json: eventsJSON, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
    
}
