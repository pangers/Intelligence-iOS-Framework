//
//  DownloadGeofencesRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// NSOperation that handles downloading geofences.
internal final class DownloadGeofencesRequestOperation: PhoenixNetworkRequestOperation {
    
    /// Array containing Geofence objects.
    var geofences: [Geofence]?
    
    /// Default initializer. Requires a network and configuration class.
    /// - Parameters:
    ///     - network: The network that will be used.
    ///     - configuration: The configuration class to use.
    init(withNetwork network: Phoenix.Network, configuration: Phoenix.Configuration) {
        let request = NSURLRequest.phx_URLRequestForDownloadGeofences(configuration)
        geofences = []
        super.init(withNetwork: network, request: request)
    }
    
    override func main() {
        super.main()
        if error != nil {
            error = NSError(domain: RequestError.domain, code: RequestError.RequestFailedError.rawValue, userInfo: nil)
            return
        }
        do {
            if let dictionary = output?.data?.phx_jsonDictionary {
                geofences = try Geofence.geofences(withJSON: dictionary)
            }
        } catch _ { // Suppress default 'error' let, so we can use our instance variable.
            error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
    }
    
}