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
public typealias PhoenixDownloadGeofencesCallback = (geofences: [Geofence]?, error:NSError?) -> Void

/// Called when a geofence is entered or exited.
internal typealias PhoenixGeofenceCallback = (geofence: Geofence, entered: Bool) -> Void

/// Phoenix coordinate object. CLLocationCoordinate2D can't be
@objc public class PhoenixCoordinate : NSObject {
    
    let longitude:Double
    let latitude:Double
    
    init(withLatitude latitude:Double, longitude:Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        guard let object = object as? PhoenixCoordinate else {
            return false
        }
        
        return object.longitude == longitude && object.latitude == latitude
    }
}

/**
*  The Phoenix Location module protocol.
*/
@objc public protocol PhoenixLocation : PhoenixModuleProtocol {
    
    func downloadGeofences(queryDetails: GeofenceQuery, callback: PhoenixDownloadGeofencesCallback?)
    
    var userLocation:PhoenixCoordinate? {
        get
    }
    
}

internal extension Phoenix {
    
    /// Location module that is responsible for managing Geofences and User Location.
    internal final class Location: PhoenixModule, PhoenixLocation, PhoenixLocationManagerDelegate {
                
        /// Callback for enter/exit geofences.
        internal let geofenceCallback: PhoenixGeofenceCallback
        
        /// Array of recently entered geofences, on exit they will be removed, ensures no duplicate API calls on reload/download of geofences.
        internal lazy var enteredGeofences = [Geofence]()
        
        /// Geofences array, loaded from Cache on launch but updated with data from server if network is available.
        /// When updated it will set the location manager to monitor the given geofences (or stop it if nil geofences
        /// are set).
        internal var geofences: [Geofence]? {
            didSet {
                guard let geofences = geofences where geofences.count > 0 else {
                    self.locationManager.stopMonitoringLocation()
                    return
                }
                
                self.locationManager.startMonitoringGeofences(geofences)
            }
        }
        
        /// The location manager
        private let locationManager:PhoenixLocationManager
        
        /// Helper property to get the userlocation, wrapping the location manager method.
        var userLocation:PhoenixCoordinate? {
            return locationManager.userLocation
        }
        
        /// Default initializer. Requires a network and configuration class.
        /// - Parameters: 
        ///     - withNetwork: The network that will be used.
        ///     - configuration: The configuration class to use.
        
        /// Default initializer. Requires a network and configuration class and a geofence enter/exit callback.
        /// - parameter network:          Instance of Network class to use.
        /// - parameter configuration:    Configuration used to configure requests.
        /// - parameter geofenceCallback: Called on enter/exit of geofence.
        /// - returns: Returns a Location object.
        internal init(withNetwork network:Network, configuration: Phoenix.Configuration, geofenceCallback: PhoenixGeofenceCallback, locationManager:PhoenixLocationManager) {
            self.geofenceCallback = geofenceCallback
            self.locationManager = locationManager
            super.init(withNetwork: network, configuration: configuration)
            self.locationManager.delegate = self
        }
        
        deinit {
            locationManager.stopMonitoringLocation()
            locationManager.stopMonitoringGeofences()
        }
        
        // MARK:- Startup and shutdown methods.
        
        /**
        Will download the geofences and put them in the monitored regions if required.
        */
        override func startup() {
            if configuration.useGeofences {
                guard let location = self.userLocation else {
                    return
                }

                let geoQuery: GeofenceQuery = GeofenceQuery.init(location: location)
                geoQuery.setDefaultValues()
                downloadGeofences(geoQuery, callback:nil)
            }
        }
        
        override func shutdown() {
            // Clear geofences.
            locationManager.stopMonitoringLocation()
            locationManager.stopMonitoringGeofences()
            geofences = nil
        }
        
        /// Download a list of geofences.
        /// - Parameter callback: Will be called with an array of PhoenixGeofence or an error.
        func downloadGeofences(queryDetails: GeofenceQuery, callback: PhoenixDownloadGeofencesCallback?) {
            // Initialise with cached geofences, startup may never succeed if networking/parsing error occurs.
            do {
                self.geofences = try Geofence.geofencesFromCache()
            } catch {
                // TODO Handle error
            }

            let operation = DownloadGeofencesRequestOperation(withNetwork: network, configuration: self.configuration, queryDetails: queryDetails)

            // set the completion block to notify the caller
            operation.completionBlock = { [weak self] in
                self?.geofences = operation.geofences
                callback?(geofences: operation.geofences, error: operation.error)
            }

            // Execute the network operation
            network.executeNetworkOperation(operation)
        }
        
        // MARK:- PhoenixLocationManagerDelegate
        
        // TODO: Re-enable this once it has been tested

        func didEnterGeofence(geofence: Geofence, withUserCoordinate: PhoenixCoordinate?) {
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
        
        func didExitGeofence(geofence: Geofence, withUserCoordinate: PhoenixCoordinate?) {
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