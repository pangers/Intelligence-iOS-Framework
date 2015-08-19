//
//  AnalyticsRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Success will be true if no errors are received and the expected amount of items in the 'Data' array is valid.
internal typealias AnalyticsSuccessCallback = (success: Bool) -> Void

/// NSOperation that handles sending analytics.
internal final class AnalyticsRequestOperation: PhoenixNetworkRequestOperation {
    
    /// Callback to trigger on completion.
    private let callback: AnalyticsSuccessCallback
    
    /// Number of events included in this request.
    private let eventCount: Int
    
    /// Default initializer. Requires a network and configuration class.
    /// - parameter network:       Networking instance that manages queueing/sending of this operation.
    /// - parameter configuration: Configuration instance used for setting up the request.
    /// - parameter eventsJSON:    Body of the request.
    /// - returns: Instance of Analytics Request Operation.
    init(withNetwork network: Phoenix.Network, configuration: Phoenix.Configuration, eventsJSON: JSONDictionaryArray, callback: AnalyticsSuccessCallback) {
        assert(eventsJSON.count > 0)
        self.callback = callback
        eventCount = eventsJSON.count
        let request = NSURLRequest.phx_httpURLRequestForAnalytics(configuration, json: eventsJSON)
        super.init(withNetwork: network, request: request)
    }
    
    override func main() {
        super.main()
        defer {
            self.callback(success: error == nil && getDataArray()?.count == eventCount)
        }
        if error != nil {
            error = NSError(domain: RequestError.domain, code: RequestError.RequestFailedError.rawValue, userInfo: nil)
            return
        }
    }
    
}