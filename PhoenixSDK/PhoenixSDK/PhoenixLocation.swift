//
//  PhoenixLocation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// A generic PhoenixGeofencesCallback in which we get either an array of PhoenixGeofence or an error.
internal typealias PhoenixGeofencesCallback = (geofences: [PhoenixGeofence]?, error:NSError?) -> Void

extension Phoenix {
    
    /// Location module that is responsible for managing Geofences and User Location.
    class Location {
        
        /// A reference to the network manager
        private let network: Network
        
        /// Default initializer. Requires a network.
        /// - Parameter network: The network that will be used.
        init(withNetwork network:Network) {
            self.network = network
        }
        
        /// Download a list of geofences.
        /// - Parameter callback: Will be called with an array of PhoenixGeofence or an error.
        func downloadGeofences(projectId: Int, callback: PhoenixGeofencesCallback?) {
            
            let operation = DownloadGeofencesRequestOperation(withNetwork: network)
            
            // set the completion block to notify the caller
            operation.completionBlock = {
                guard let callback = callback else {
                    return
                }
                
                // TODO: Parse geo fences...
                let gf = [PhoenixGeofence]()
                
                callback(geofences: gf, error: operation.error)
            }
            
            // Execute the network operation
            network.executeNetworkOperation(operation)
        }
        
    }
    
}