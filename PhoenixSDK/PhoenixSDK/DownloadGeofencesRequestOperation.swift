//
//  DownloadGeofencesRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class DownloadGeofencesRequestOperation: PhoenixNetworkRequestOperation {
    
    var geofences: JSONDictionary?
    
    init(withNetwork network: Phoenix.Network, configuration: Phoenix.Configuration) {
        let request = NSURLRequest.phx_httpURLRequestForDownloadGeofences(configuration)
        super.init(network: network, request: request)
    }
    
    override func main() {
        super.main()
        // TODO: Handle error?
        
        guard let dictionary = self.output?.data?.phx_jsonDictionary else {
            return
        }
        geofences = dictionary
    }
    
}