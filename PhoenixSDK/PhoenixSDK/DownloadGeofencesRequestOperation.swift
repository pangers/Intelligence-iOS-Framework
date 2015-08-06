//
//  DownloadGeofencesRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class DownloadGeofencesRequestOperation: PhoenixNetworkRequestOperation {
    
    init(withNetwork network: Phoenix.Network, projectId: Int) {
        let request = NSURLRequest.phx_httpURLRequestForDownloadGeofences(projectId)
        super.init(network: network, request: request)
    }
    
}