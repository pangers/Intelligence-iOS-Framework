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

/// Phoenix coordinate object. CLLocationCoordinate2D can't be used as an optional.
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
    
    func downloadGeofences(callback: PhoenixDownloadGeofencesCallback?) -> Bool

    func downloadGeofences(withCoordinates coordinates:PhoenixCoordinate, callback: PhoenixDownloadGeofencesCallback?)
}

internal extension Phoenix {
    
    /// Location module that is responsible for managing Geofences and User Location.
    internal final class Location: PhoenixModule, PhoenixLocation, PhoenixLocationManagerDelegate, PhoenixLocationProvider {
        
        /// A reference to the analytics module so we can track the geofences entered/exited events
        internal weak var analytics:PhoenixAnalytics?
        
        /// Array of recently entered geofences, on exit they will be removed, ensures no duplicate API calls on reload/download of geofences.
        internal lazy var enteredGeofences = [Geofence]()
        
        /// Geofences array, loaded from Cache on launch but updated with data from server if network is available.
        /// When updated it will set the location manager to monitor the given geofences (or stop it if nil geofences
        /// are set).
        internal var geofences: [Geofence]? {
            didSet {
                guard let geofences = geofences where geofences.count > 0 else {
                    self.locationManager.stopMonitoringGeofences()
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
        
        /// Default initializer. Requires a network and configuration class and a geofence enter/exit callback.
        /// - parameter delegate:         Delegate used to notify developer of an event.
        /// - parameter network:          Instance of Network class to use.
        /// - parameter configuration:    Configuration used to configure requests.
        /// - parameter geofenceCallback: Called on enter/exit of geofence.
        /// - returns: Returns a Location object.
        internal init(withDelegate delegate: PhoenixInternalDelegate, network: Network, configuration: Phoenix.Configuration, locationManager:PhoenixLocationManager) {
            self.locationManager = locationManager
            super.init(withDelegate: delegate, network: network, configuration: configuration)
            self.locationManager.delegate = self
        }
        
        deinit {
            locationManager.stopUpdatingLocation()
            locationManager.stopMonitoringGeofences()
        }
        
        // MARK:- Startup and shutdown methods.
        
        /**
        Will download the geofences and put them in the monitored regions if required.
        */
        override func startup(completion: (success: Bool) -> ()) {
            super.startup { [weak self, weak configuration] (success) -> () in
                if !success {
                    completion(success: false)
                    return
                }
                // TODO: Remove 'usegeofences' flag.
                if configuration?.useGeofences == true {
                    self?.downloadGeofences(nil)
                }
            }
            
        }
        
        /**
        Stops monitoring and nils the geofences.
        */
        override func shutdown() {
            // Clear geofences.
            locationManager.stopUpdatingLocation()
            locationManager.stopMonitoringGeofences()
            geofences = nil
            
            super.shutdown()
        }
        
        /**
        Convenience method to download the geofences from the default values.
        
        - parameter callback: The callback to be notified with the geofences and 
        error if any.
        
        - returns: True if the download was enqueued
        */
        func downloadGeofences(callback: PhoenixDownloadGeofencesCallback?) -> Bool {
            guard let location = self.userLocation else {
                return false
            }
            
            let geofenceQuery: GeofenceQuery = GeofenceQuery.init(location: location)
            geofenceQuery.setDefaultValues()
            downloadGeofences(geofenceQuery, callback: callback)
            return true
        }
        
        
        func downloadGeofences(withCoordinates coordinates:PhoenixCoordinate, callback: PhoenixDownloadGeofencesCallback?) {
            let geofenceQuery: GeofenceQuery = GeofenceQuery.init(location: coordinates)
            geofenceQuery.setDefaultValues()
            downloadGeofences(geofenceQuery, callback: callback)
        }

        /// Download a list of geofences.
        /// - Parameter callback: Will be called with an array of PhoenixGeofence or an error.
        func downloadGeofences(queryDetails: GeofenceQuery, callback: PhoenixDownloadGeofencesCallback?) {
            // Initialise with cached geofences, startup may never succeed if networking/parsing error occurs.
            do {
                self.geofences = try Geofence.geofencesFromCache()
            } catch {
                // TODO: Warning: Handle the error
            }

//            TODO Sort out
//            let operation = DownloadGeofencesRequestOperation(oauth: network.loggedInUserOAuth), phoenix: nil)
//
//            // set the completion block to notify the caller
//            operation.completionBlock = { [weak self] in
//                self?.geofences = operation.geofences
//                callback?(geofences: operation.geofences, error: operation.error)
//            }
//
//            // Execute the network operation
//            network.executeNetworkOperation(operation)
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

        func didUpdateLocationWithCoordinate(coordinate: PhoenixCoordinate) {
            if configuration.useGeofences {
                downloadGeofences(withCoordinates: coordinate, callback: nil)
            }
        }
    }
    
}