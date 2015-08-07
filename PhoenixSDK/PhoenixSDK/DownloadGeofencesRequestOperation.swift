//
//  DownloadGeofencesRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// NSOperation that handles downloading geofences.
class DownloadGeofencesRequestOperation: PhoenixNetworkRequestOperation {
    
    /// Dictionary containing geofences in JSONDictionary format.
    var geofences: JSONDictionary?
    
    /// Default initializer. Requires a network and configuration class.
    /// - Parameters:
    ///     - network: The network that will be used.
    ///     - configuration: The configuration class to use.
    init(withNetwork network: Phoenix.Network, configuration: Phoenix.Configuration) {
        let request = NSURLRequest.phx_httpURLRequestForDownloadGeofences(configuration)
        super.init(network: network, request: request)
    }
    
    override func main() {
        super.main()
        if error != nil {
            error = NSError(domain: LocationError.domain, code: LocationError.RequestFailedError.rawValue, userInfo: nil)
            return
        }
        guard let dictionary = output?.data?.phx_jsonDictionary else {
            return
        }
        geofences = dictionary
    }
    
}