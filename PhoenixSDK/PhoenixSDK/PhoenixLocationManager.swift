//
//  LocationManager.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

internal extension Phoenix {
    
    internal class LocationManager: NSObject, CLLocationManagerDelegate {
        
        /// Singleton that manages CLLocation updates.
        static let sharedInstance = LocationManager()
        
        /// Current analytics instance.
        weak var analytics: Analytics?
        
        /// Current location instance.
        weak var location: Location?
        
        private var privateLocationManager: CLLocationManager?
        
        /// Returns a CLLocationManager if we are allowed to instantiate one.
        internal var locationManager: CLLocationManager? {
            if hasLocationServicesEnabled && hasSignificantLocationChangesEnabled {
                if privateLocationManager == nil {
                    // Create location manager if we are allowed to monitor.
                    privateLocationManager = CLLocationManager()
                    privateLocationManager?.startMonitoringSignificantLocationChanges()
                    startMonitoringGeofences()
                }
            } else {
                // Clear location manager if we aren't allowed to monitor...
                privateLocationManager?.stopMonitoringSignificantLocationChanges()
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
        
        // MARK:- Geofences
        
        /// Start monitoring geofences.
        func startMonitoringGeofences() {
            stopMonitoringGeofences()
            if locationManager != nil && hasRegionMonitoringEnabled {
                // Start monitoring our new geofences array.
                location?.geofences?.map({ locationManager?.startMonitoringForRegion(CLCircularRegion(
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
        
        
        // MARK:- CLLocationManagerDelegate
        
        /// Called when a geofence is entered.
        /// - parameter manager: CLLocationManager instance.
        /// - parameter region:  CLRegion we just entered.
        func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
            guard let geofence = location?.geofences?.filter({ $0.id.description == region.identifier }).first else {
                assert(false, "Entered region we don't know about?")
                return
            }
            analytics?.trackGeofenceEnteredEvent(geofence)
        }
        
        /// Called when a geofence is exited.
        /// - parameter manager: CLLocationManager instance.
        /// - parameter region:  CLRegion we just exited.
        func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
            guard let geofence = location?.geofences?.filter({ $0.id.description == region.identifier }).first else {
                assert(false, "Exited region we don't know about?")
                return
            }
            analytics?.trackGeofenceExitedEvent(geofence)
        }
    }
}