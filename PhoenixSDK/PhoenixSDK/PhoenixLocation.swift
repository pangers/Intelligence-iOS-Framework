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
    
    /**
    Downloads a list of geofences using the given query details
    
    - parameter queryDetails: The geofence query to retrieve.
    - parameter callback:     The callback that will be notified upon success/error.
    */
    func downloadGeofences(queryDetails: GeofenceQuery, callback: PhoenixDownloadGeofencesCallback?)
    
    /// Geofences array, loaded from Cache on startup but updated with data from server if network is available.
    /// When updated it will set the location manager to monitor the given geofences if we have permissions.
    /// If we don't have permissions it will do nothing, and if we don't receive any geofence, we will
    /// stop monitoring the previous geofences.
    /// As a result, this holds the list of geofences that are currently monitored if we have permissions.
    var geofences: [Geofence]? { get }

}

internal extension Phoenix {
    
    /// Location module that is responsible for managing Geofences and User Location.
    internal final class Location: PhoenixModule, PhoenixLocation, PhoenixLocationManagerDelegate, PhoenixLocationProvider {
        
        /// The last coordinate we received.
        private var lastLocation:PhoenixCoordinate?
        
        /// A reference to the analytics module so we can track the geofences entered/exited events
        internal weak var analytics:PhoenixAnalytics?
        
        /// Array of recently entered geofences, on exit they will be removed, ensures no duplicate API calls on reload/download of geofences.
        internal lazy var enteredGeofences = [Int:Geofence]()
        
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
        
        var userLocation:PhoenixCoordinate? {
            return locationManager.userLocation
        }
        
        /// Default initializer. Requires a network and configuration class and a geofence enter/exit callback.
        /// - parameter network:          Instance of Network class to use.
        /// - parameter configuration:    Configuration used to configure requests.
        /// - parameter geofenceCallback: Called on enter/exit of geofence.
        /// - returns: Returns a Location object.
        internal init(withNetwork network:Network, configuration: Phoenix.Configuration, locationManager:PhoenixLocationManager) {
            self.locationManager = locationManager
            super.init(withNetwork: network, configuration: configuration)
            self.locationManager.delegate = self
            
            // Initialize the last known location with the user's one.
            lastLocation = userLocation
        }
        
        deinit {
            locationManager.stopUpdatingLocation()
            locationManager.stopMonitoringGeofences()
        }
        
        // MARK:- Startup and shutdown methods.
        
        /**
        Will download the geofences and put them in the monitored regions if required.
        */
        override func startup() {
            super.startup()
            
            if configuration.useGeofences {
                // Get the geofences from the cache if possible.
                self.geofences = try? Geofence.geofencesFromCache()
                
                if !downloadGeofences(nil) {
                    
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
        
        func downloadGeofences(callback: PhoenixDownloadGeofencesCallback?) -> Bool {
            guard let location = self.userLocation else {
                // Start getting locations so we will obtain geofences later on.
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

        func downloadGeofences(queryDetails: GeofenceQuery, callback: PhoenixDownloadGeofencesCallback?) {
            let operation = DownloadGeofencesRequestOperation(configuration: configuration, network: network)

            // set the completion block to notify the caller
            operation.completionBlock = { [weak self] in
                let error = operation.output?.error
                let geofences = operation.geofences
                
                if error == nil && geofences != nil {
                    self?.geofences = operation.geofences
                }
                
                callback?(geofences: operation.geofences, error: operation.output?.error)
            }

            // Execute the network operation
            network.enqueueOperation(operation)
        }
        
        func trackGeofenceEntered(geofence:Geofence) {
            let geofenceEvent = Phoenix.Event(withType: "Phoenix.Location.Geofence.Enter")
            geofenceEvent.targetId = geofence.id
            analytics?.track(geofenceEvent)
            
            let viewController = UIAlertController(title: "Geofence event", message: geofenceEvent.eventType, preferredStyle: .Alert)
            viewController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
                viewController.dismissViewControllerAnimated(true, completion:nil)
            }))
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(viewController, animated:true, completion: nil)
        }

        func trackGeofenceExited(geofence:Geofence) {
            let geofenceEvent = Phoenix.Event(withType: "Phoenix.Location.Geofence.Exit")
            geofenceEvent.targetId = geofence.id
            analytics?.track(geofenceEvent)
            
            let viewController = UIAlertController(title: "Geofence event", message: geofenceEvent.eventType, preferredStyle: .Alert)
            viewController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
                viewController.dismissViewControllerAnimated(true, completion:nil)
            }))
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(viewController, animated:true, completion: nil)
        }

        // MARK:- PhoenixLocationManagerDelegate

        func didEnterGeofence(geofence: Geofence, withUserCoordinate: PhoenixCoordinate?) {
            if configuration.useGeofences == false {
                locationManager.stopMonitoringGeofences()
                return
            }
            
            self.enteredGeofences[geofence.id] = geofence
            self.trackGeofenceEntered(geofence)
        }
        
        func didExitGeofence(geofence: Geofence, withUserCoordinate: PhoenixCoordinate?) {
            if configuration.useGeofences == false {
                locationManager.stopMonitoringGeofences()
                return
            }
            
            self.enteredGeofences[geofence.id] = nil
            self.trackGeofenceExited(geofence)
        }

        func didUpdateLocationWithCoordinate(coordinate: PhoenixCoordinate) {
            if configuration.useGeofences && lastLocation != coordinate {
                lastLocation = coordinate
                downloadGeofences(withCoordinates: coordinate, callback: nil)
            }
        }
    }
    
}