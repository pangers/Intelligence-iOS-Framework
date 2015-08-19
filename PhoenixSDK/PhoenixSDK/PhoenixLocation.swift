//
//  PhoenixLocation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// A generic PhoenixGeofencesCallback in which error will be populated if something went wrong, geofences will be empty if no geofences exist (or error occurs).
internal typealias PhoenixGeofencesCallback = (geofences: [Geofence]?, error:NSError?) -> Void

internal extension Phoenix {
    
    /// Location module that is responsible for managing Geofences and User Location.
    internal final class Location: PhoenixModuleProtocol {
        
        /// A reference to the network manager
        private let network: Network
        private let configuration: Phoenix.Configuration
        
        /// Geofences array, loaded from Cache on launch but updated with data from server if network is available.
        internal var geofences: [Geofence]? {
            didSet {
                print("New Geofences: \(geofences)")
                // Attempt to start monitoring these new geofences.
                LocationManager.sharedInstance.startMonitoringGeofences()
            }
        }
        
        /// Default initializer. Requires a network and configuration class.
        /// - Parameters: 
        ///     - withNetwork: The network that will be used.
        ///     - configuration: The configuration class to use.
        internal init(withNetwork network:Network, configuration: Phoenix.Configuration) {
            self.network = network
            self.configuration = configuration
            LocationManager.sharedInstance.location = self
            // Initialise with cached geofences, startup may never succeed if networking/parsing error occurs.
            if self.configuration.useGeofences {
                do {
                    self.geofences = try Geofence.geofencesFromCache()
                    LocationManager.sharedInstance.startMonitoringGeofences()
                } catch {
                    // Ignore error...
                }
                print("Geofences: \(geofences)")
            }
        }
        
        @objc func startup() {
            // TODO: Setup location monitoring, etc..
            do {
                try downloadGeofences { [weak self] (geofences, error) -> Void in
                    if let geofences = geofences {
                        self?.geofences = geofences
                    }
                }
            }
            catch {
                // Flag Disabled.
            }
        }
        
        func shutdown() {
            // Clear geofences.
            geofences = nil
        }
        
        /// Download a list of geofences.
        /// - Parameter callback: Will be called with an array of PhoenixGeofence or an error.
        internal func downloadGeofences(callback: PhoenixGeofencesCallback?) throws {
            if configuration.useGeofences {
                let operation = DownloadGeofencesRequestOperation(withNetwork: network, configuration: self.configuration)
                
                // set the completion block to notify the caller
                operation.completionBlock = {
                    guard let callback = callback else {
                        return
                    }
                    callback(geofences: operation.geofences, error: operation.error)
                }
                
                // Execute the network operation
                network.executeNetworkOperation(operation)
            } else {
                throw GeofenceError.CannotRequestGeofencesWhenDisabled
            }
        }
    }
    
}