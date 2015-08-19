//
//  PhoenixLocation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

/// A generic PhoenixGeofencesCallback in which error will be populated if something went wrong, geofences will be empty if no geofences exist (or error occurs).
internal typealias PhoenixGeofencesCallback = (geofences: [Geofence]?, error:NSError?) -> Void

/// Called when a geofence is entered or exited.
internal typealias PhoenixGeofenceEnteredExitedCallback = (geofence: Geofence, entered: Bool) -> Void

internal extension Phoenix {
    
    /// Location module that is responsible for managing Geofences and User Location.
    internal final class Location: NSObject, PhoenixModuleProtocol, CLLocationManagerDelegate {
        
        /// A reference to the network manager
        private let network: Network
        /// Configuration instance used for NSURLRequests.
        private let configuration: Phoenix.Configuration
        /// Callback for enter/exit geofences.
        internal let geofenceCallback: PhoenixGeofenceEnteredExitedCallback
        
        /// Geofences array, loaded from Cache on launch but updated with data from server if network is available.
        internal var geofences: [Geofence]? {
            didSet {
                print("New Geofences: \(geofences)")
                // Attempt to start monitoring these new geofences.
                startMonitoringGeofences()
            }
        }
        
        /// Default initializer. Requires a network and configuration class.
        /// - Parameters: 
        ///     - withNetwork: The network that will be used.
        ///     - configuration: The configuration class to use.
        internal init(withNetwork network:Network, configuration: Phoenix.Configuration, geofenceCallback: PhoenixGeofenceEnteredExitedCallback) {
            self.network = network
            self.configuration = configuration
            self.geofenceCallback = geofenceCallback
            // Initialise with cached geofences, startup may never succeed if networking/parsing error occurs.
            if self.configuration.useGeofences {
                do {
                    self.geofences = try Geofence.geofencesFromCache()
                } catch {
                    // Ignore error...
                }
                print("Geofences: \(geofences)")
            }
            super.init()
            startMonitoringGeofences()
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
        
        
        // MARK:- CLLocationManager
        
        private var privateLocationManager: CLLocationManager?
        /// Returns a CLLocationManager if we are allowed to instantiate one.
        internal var locationManager: CLLocationManager? {
            if hasLocationServicesEnabled && hasSignificantLocationChangesEnabled {
                if privateLocationManager == nil {
                    // Create location manager if we are allowed to monitor.
                    privateLocationManager = CLLocationManager()
                    privateLocationManager?.delegate = self
                    privateLocationManager?.startMonitoringSignificantLocationChanges()
                    startMonitoringGeofences()
                }
            } else {
                // Clear location manager if we aren't allowed to monitor...
                privateLocationManager?.stopMonitoringSignificantLocationChanges()
                privateLocationManager?.delegate = nil
                stopMonitoringGeofences()
                privateLocationManager = nil
            }
            return privateLocationManager
        }
        
        deinit {
            privateLocationManager?.stopMonitoringSignificantLocationChanges()
            stopMonitoringGeofences()
            privateLocationManager = nil
        }
        
        /// Determines if user has allowed us access.
        var hasLocationServicesEnabled: Bool {
            return CLLocationManager.authorizationStatus() != .Restricted && CLLocationManager.authorizationStatus() != .Denied
        }
        
        /// Determines if developer has requested the significant changes event and user has accepted.
        var hasSignificantLocationChangesEnabled: Bool {
            return CLLocationManager.significantLocationChangeMonitoringAvailable()
        }
        
        /// Determines if developer has requested the region monitoring permission and user has accepted.
        var hasRegionMonitoringEnabled: Bool {
            return CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self)
        }
        
        /// Returns current location if available.
        internal var userLocation: CLLocationCoordinate2D? {
            return locationManager?.location?.coordinate
        }
        
        
        // MARK:- CLLocationManagerDelegate
        
        /// Called when a geofence is entered.
        /// - parameter manager: CLLocationManager instance.
        /// - parameter region:  CLRegion we just entered.
        func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
            guard let geofence = geofences?.filter({ $0.id.description == region.identifier }).first else {
                assert(false, "Entered region we don't know about?")
                return
            }
            geofenceCallback(geofence: geofence, entered: true)
        }
        
        /// Called when a geofence is exited.
        /// - parameter manager: CLLocationManager instance.
        /// - parameter region:  CLRegion we just exited.
        func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
            guard let geofence = geofences?.filter({ $0.id.description == region.identifier }).first else {
                assert(false, "Exited region we don't know about?")
                return
            }
            geofenceCallback(geofence: geofence, entered: false)
        }
        
        
        // MARK:- Geofences
        
        /// Start monitoring geofences.
        func startMonitoringGeofences() {
            stopMonitoringGeofences()
            if locationManager != nil && hasRegionMonitoringEnabled {
                // Start monitoring our new geofences array.
                geofences?.map({ locationManager?.startMonitoringForRegion(CLCircularRegion(
                    center: CLLocationCoordinate2DMake($0.latitude, $0.longitude),
                    radius: $0.radius,
                    identifier: $0.id.description)) })
            }
        }
        
        /// Stop monitoring geofences.
        func stopMonitoringGeofences() {
            // Stop monitoring any regions we may be currently monitoring (such as old geofences).
            locationManager?.monitoredRegions.map({ self.locationManager?.stopMonitoringForRegion($0) })
        }
    }
    
}