//
//  PhoenixLocation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

/// A generic PhoenixDownloadGeofencesCallback in which error will be populated if something went wrong, geofences will be empty if no geofences exist (or error occurs).
internal typealias PhoenixDownloadGeofencesCallback = (geofences: [Geofence]?, error:NSError?) -> Void

/// Called when a geofence is entered or exited.
internal typealias PhoenixGeofenceCallback = (geofence: Geofence, entered: Bool) -> Void

internal extension Phoenix {
    
    /// Location module that is responsible for managing Geofences and User Location.
    internal final class Location: NSObject, PhoenixModuleProtocol, CLLocationManagerDelegate {
        
        internal weak var phoenix: Phoenix!
        
        /// A reference to the Network manager.
        private var network: Network {
            return phoenix.network
        }
        /// Configuration instance used for NSURLRequests.
        private var configuration: Phoenix.Configuration {
            return phoenix.internalConfiguration
        }
        
        /// Callback for enter/exit geofences.
        internal let geofenceCallback: PhoenixGeofenceCallback
        /// Array of recently entered geofences, on exit they will be removed, ensures no duplicate API calls on reload/download of geofences.
        internal lazy var enteredGeofences = [Geofence]()
        /// Flag used for testing to disable CLLocationManager.
        internal var testLocation: Bool = false
        
        /// Geofences array, loaded from Cache on launch but updated with data from server if network is available.
        internal var geofences: [Geofence]? {
            didSet {
                // Attempt to start monitoring these new geofences.
                startMonitoringGeofences()
            }
        }
        
        internal init(geofenceCallback: PhoenixGeofenceCallback) {
            self.geofenceCallback = geofenceCallback
            super.init()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("enteredBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("enteredForeground:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        }
        
        @objc func enteredBackground(notification: NSNotification) {
            // Reduce accuracy on background
            privateLocationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
        
        @objc func enteredForeground(notification: NSNotification) {
            // Restore accuracy on foreground
            privateLocationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        deinit {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
            privateLocationManager?.stopUpdatingLocation()
            stopMonitoringGeofences()
            privateLocationManager = nil
        }
        
        func startup() {
            do {
                geofences = try Geofence.geofencesFromCache()
                try downloadGeofences { [weak self] (geofences, error) -> Void in
                    if let geofences = geofences {
                        self?.geofences = geofences
                    }
                }
                startMonitoringGeofences()
            }
            catch {
                // Flag Disabled.
            }
        }
        
        func shutdown() {
            // Clear geofences.
            stopMonitoringGeofences()
            geofences = nil
        }
        
        /// Download a list of geofences.
        /// - Parameter callback: Will be called with an array of PhoenixGeofence or an error.
        internal func downloadGeofences(callback: PhoenixDownloadGeofencesCallback?) throws {
            if configuration.useGeofences {
                let operation = DownloadGeofencesRequestOperation(oauth: phoenix.bestSDKUserOAuth, phoenix: phoenix)
                operation.completionBlock = { [weak operation] in
                    callback?(geofences: operation?.geofences, error: operation?.output?.error)
                }
                
                // Execute the network operation
                network.enqueueOperation(operation)
            } else {
                throw GeofenceError.CannotRequestGeofencesWhenDisabled
            }
        }
        
        
        // MARK:- CLLocationManager
        
        private var privateLocationManager: CLLocationManager?
        /// Returns a CLLocationManager if we are allowed to instantiate one.
        internal var locationManager: CLLocationManager? {
            if testLocation { return nil }
            if hasLocationServicesEnabled {
                if privateLocationManager == nil {
                    // Create location manager if we are allowed to monitor.
                    privateLocationManager = CLLocationManager()
                    privateLocationManager?.delegate = self
                    privateLocationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    privateLocationManager?.startUpdatingLocation()
                    startMonitoringGeofences()
                }
            } else {
                // Clear location manager if we aren't allowed to monitor...
                privateLocationManager?.stopUpdatingLocation()
                privateLocationManager?.delegate = nil
                stopMonitoringGeofences()
                privateLocationManager = nil
            }
            return privateLocationManager
        }
        
        /// Determines if user has allowed us access.
        var hasLocationServicesEnabled: Bool {
            // Note: We should consider using significant location changes in certain circumstances.
            return CLLocationManager.authorizationStatus() != .Restricted && CLLocationManager.authorizationStatus() != .Denied &&
                CLLocationManager.locationServicesEnabled()
        }
        
        /// Determines if developer has requested the region monitoring permission and user has accepted.
        var hasRegionMonitoringEnabled: Bool {
            return CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self)
        }
        
        /// Returns current location if available.
        internal var userLocation: CLLocationCoordinate2D? {
            if testLocation { return nil }
            return locationManager?.location?.coordinate
        }
        
        
        // MARK:- CLLocationManagerDelegate
        
        /// Called when authorization status changes, refresh our geofences states.
        /// - parameter manager: CLLocationManager instance.
        /// - parameter status:  In response to user enabling/disabling location services.
        func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            // TODO: Re-enable this once it has been tested
            //privateLocationManager?.monitoredRegions.map({ self.privateLocationManager?.requestStateForRegion($0) })
        }

        /// Called when a region is added.
        /// - parameter manager: CLLocationManager instance.
        /// - parameter region:  Region we started monitoring.
        func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
            // TODO: Re-enable this once it has been tested
            //privateLocationManager?.requestStateForRegion(region)
        }

        /// Called to determine state of a region by didStartMonitoringForRegion.
        /// - parameter manager: Current location manager.
        /// - parameter state:   Inside or Outside.
        /// - parameter region:  CLRegion we just entered/exited.
        func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
            switch state {
            case .Inside:
                entered(region)
            case .Outside:
                exited(region)
            default:
                break
            }
        }

        /// Called when a geofence is entered.
        /// - parameter manager: CLLocationManager instance.
        /// - parameter region:  CLRegion we just entered.
        func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
            entered(region)
        }
        
        /// Called when a geofence is exited.
        /// - parameter manager: CLLocationManager instance.
        /// - parameter region:  CLRegion we just exited.
        func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
            exited(region)
        }
        
        
        // MARK:- Geofences
        
        /// Start monitoring geofences.
        func startMonitoringGeofences() {
            // TODO: Re-enable this once it has been tested
//            if testLocation || configuration.useGeofences == false {
//                return
//            }
//            
//            stopMonitoringGeofences()
//            
//            if locationManager != nil && hasRegionMonitoringEnabled {
//                // Start monitoring our new geofences array.
//                geofences?.forEach({
//                    let region = CLCircularRegion(
//                        center: CLLocationCoordinate2DMake($0.latitude, $0.longitude),
//                        radius: $0.radius,
//                        identifier: $0.id.description)
//                    locationManager?.startMonitoringForRegion(region)
//                })
//            }
        }
        
        /// Stop monitoring geofences.
        func stopMonitoringGeofences() {
            // TODO: Re-enable this once it has been tested
//            if testLocation {
//                return
//            }
//            
//            if configuration.useGeofences == false {
//                return
//            }
//            
//            // Stop monitoring any regions we may be currently monitoring (such as old geofences).
//            locationManager?.monitoredRegions.forEach({
//                self.locationManager?.stopMonitoringForRegion($0)
//            })
        }
        
        /// Returns relevant geofence for a region or nil.
        /// - parameter region: Region to compare id with geofence array.
        /// - returns: Geofence from geofences array.
        private func geofenceForRegion(region: CLRegion) -> Geofence? {
            guard let geofence = geofences?.filter({ $0.id.description == region.identifier }).first else {
                assert(false, "Entered region we don't know about?")
                return nil
            }
            return geofence
        }
        
        /// Called when a region is entered.
        /// - parameter region: CLRegion we just entered.
        private func entered(region: CLRegion) {
            // TODO: Re-enable this once it has been tested
//            if configuration.useGeofences == false {
//                return
//            }
//            
//            guard let geofence = geofenceForRegion(region) else {
//                return
//            }
//            
//            objc_sync_enter(self)
//            if !enteredGeofences.contains(geofence) {
//                enteredGeofences.append(geofence)
//                geofenceCallback(geofence: geofence, entered: true)
//            }
//            objc_sync_exit(self)
        }
        
        /// Called when a region is exited.
        /// - parameter region: CLRegion we just exited.
        private func exited(region: CLRegion) {
            // TODO: Re-enable this once it has been tested
//            if configuration.useGeofences == false { return }
//            guard let geofence = geofenceForRegion(region) else { return }
//            objc_sync_enter(self)
//            if enteredGeofences.contains(geofence) {
//                geofenceCallback(geofence: geofence, entered: false)
//                enteredGeofences = enteredGeofences.filter({$0 != geofence})
//            }
//            objc_sync_exit(self)
        }
    }
    
}