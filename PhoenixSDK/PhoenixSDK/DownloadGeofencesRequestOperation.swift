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
    
    /// Array containing Geofence objects.
    var geofences: [Geofence]?
    
    /// Default initializer. Requires a network and configuration class.
    /// - Parameters:
    ///     - network: The network that will be used.
    ///     - configuration: The configuration class to use.
    init(withNetwork network: Phoenix.Network, configuration: Phoenix.Configuration) {
        let request = NSURLRequest.phx_httpURLRequestForDownloadGeofences(configuration)
        geofences = []
        super.init(network: network, request: request)
    }
    
    override func main() {
        super.main()
        defer {
            if geofences?.count == 0 || error != nil {
                error = NSError(domain: LocationError.domain, code: LocationError.RequestFailedError.rawValue, userInfo: nil)
            }
        }
        do {
            if let dictionary = output?.data?.phx_jsonDictionary {
                geofences = try Geofence.geofences(withJSON: dictionary)
            }
        } catch {
            
        }
    }
    
}