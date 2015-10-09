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

@objc(PHXLocationDelegate) public protocol PhoenixLocationDelegate {
    
    optional func phoenixLocation(location: PhoenixLocationProtocol, didEnterGeofence geofence: Geofence)

    optional func phoenixLocation(location: PhoenixLocationProtocol, didExitGeofence geofence: Geofence)
    
    optional func phoenixLocation(location: PhoenixLocationProtocol, didStartMonitoringGeofence: Geofence)

    optional func phoenixLocation(location: PhoenixLocationProtocol, didFailMonitoringGeofence: Geofence)

    optional func phoenixLocation(location: PhoenixLocationProtocol, didStopMonitoringGeofence: Geofence)
}

/**
*  The Phoenix Location module protocol.
*/
@objc(PHXLocation) public protocol PhoenixLocationProtocol : PhoenixModuleProtocol {
    
    /**
    Downloads a list of geofences using the given query details
    
    - parameter queryDetails: The geofence query to retrieve.
    - parameter callback:     The callback that will be notified upon success/error.
    */
    func downloadGeofences(queryDetails: GeofenceQuery, callback: PhoenixDownloadGeofencesCallback?)
    
    func isMonitoringGeofences() -> Bool
    
    /**
    Starts monitoring the given geofences.
    
    - parameter geofences: The geofences to monitor.
    
    */
    func startMonitoringGeofences(geofences:[Geofence])
    
    /**
    Stops monitoring the geofences, and flushes the ones the location module keeps.
    */
    func stopMonitoringGeofences()
    
    /**
    Sets the location accuracy to use when monitoring regions. Defaults to kCLLocationAccuracyHundredMeters.
    
    - parameter accuracy: The accuracy
    */
    func setLocationAccuracy(accuracy:CLLocationAccuracy)
    
    /// Geofences array, loaded from Cache on startup but updated with data from server if network is available.
    /// When updated it will set the location manager to monitor the given geofences if we have permissions.
    /// If we don't have permissions it will do nothing, and if we don't receive any geofence, we will
    /// stop monitoring the previous geofences.
    /// As a result, this holds the list of geofences that are currently monitored if we have permissions.
    var geofences: [Geofence]? { get }
    
    /// The delegate that will be notified upon entering/exiting a geofence.
    var locationDelegate:PhoenixLocationDelegate? { get set }
    
}

/// Phoenix coordinate object. CLLocationCoordinate2D can't be used as an optional.
/// Furthermore, not providing a custom location object would force the developers to
/// always require CoreLocation even if they don't need to use it.
@objc(PHXCoordinate) public class PhoenixCoordinate : NSObject {
    
    let longitude:Double
    let latitude:Double
    
    public init(withLatitude latitude:Double, longitude:Double) {
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

/// Location module that is responsible for managing Geofences and User Location.
internal final class PhoenixLocation: PhoenixModule, PhoenixLocationProtocol, PhoenixLocationManagerDelegate, PhoenixLocationProvider {
    
    /// The last coordinate we received.
    private var lastLocation:PhoenixCoordinate?
    
    var locationDelegate:PhoenixLocationDelegate?
    
    /// A reference to the analytics module so we can track the geofences entered/exited events
    internal weak var analytics: PhoenixAnalyticsProtocol?
    
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
    internal init(withDelegate delegate:PhoenixInternalDelegate,network:Network, configuration: Phoenix.Configuration, locationManager:PhoenixLocationManager) {
        self.locationManager = locationManager
        super.init(withDelegate:delegate, network: network, configuration: configuration)
        self.locationManager.delegate = self
        
        // Initialize the last known location with the user's one.
        lastLocation = userLocation
    }
    
    // MARK:- Startup and shutdown methods.
    
    override func startup(completion: (success: Bool) -> ()) {
        super.startup(completion)
    }
    
    /**
    Stops monitoring and nils the geofences.
    */
    override func shutdown() {
        // Clear geofences.
        geofences = nil
        
        super.shutdown()
    }
    
    // MARK:- Download geofences
    
    func downloadGeofences(queryDetails: GeofenceQuery, callback: PhoenixDownloadGeofencesCallback?) {
        let operation = DownloadGeofencesRequestOperation(oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, query:queryDetails, callback: { (returnedOperation) -> () in
            guard let downloadGeofencesOperation = returnedOperation as? DownloadGeofencesRequestOperation else {
                assertionFailure("Invalid operation")
                return
            }
            let error = downloadGeofencesOperation.output?.error
            let geofences = downloadGeofencesOperation.geofences
            callback?(geofences: geofences, error: error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    func isMonitoringGeofences() -> Bool {
        return self.locationManager.isMonitoringGeofences()
    }
    
    func startMonitoringGeofences(geofences:[Geofence]) {
        self.locationManager.startMonitoringGeofences(geofences)
    }
    
    func stopMonitoringGeofences() {
        self.locationManager.stopMonitoringGeofences()
    }
    
    func setLocationAccuracy(accuracy:CLLocationAccuracy) {
        self.locationManager.setLocationAccuracy(accuracy)
    }
    
    func trackGeofenceEntered(geofence:Geofence) {
        let geofenceEvent = Event(withType: "Phoenix.Location.Geofence.Enter")
        geofenceEvent.targetId = String(geofence.id)
        analytics?.track(geofenceEvent)
    }
    
    func trackGeofenceExited(geofence:Geofence) {
        let geofenceEvent = Event(withType: "Phoenix.Location.Geofence.Exit")
        geofenceEvent.targetId = String(geofence.id)
        analytics?.track(geofenceEvent)
    }
    
    // MARK:- PhoenixLocationManagerDelegate
    
    func didEnterGeofence(geofence: Geofence, withUserCoordinate: PhoenixCoordinate?) {
        self.locationDelegate?.phoenixLocation?(self, didEnterGeofence: geofence)
        self.enteredGeofences[geofence.id] = geofence
        self.trackGeofenceEntered(geofence)
    }
    
    func didExitGeofence(geofence: Geofence, withUserCoordinate: PhoenixCoordinate?) {
        self.locationDelegate?.phoenixLocation?(self, didExitGeofence: geofence)
        self.enteredGeofences[geofence.id] = nil
        self.trackGeofenceExited(geofence)
    }
    
    func didUpdateLocationWithCoordinate(coordinate:PhoenixCoordinate) {
        
    }
    
    func didStartMonitoringGeofence(geofence:Geofence) {
        self.locationDelegate?.phoenixLocation?(self, didStartMonitoringGeofence: geofence)
    }
    
    func didFailMonitoringGeofence(geofence:Geofence) {
        self.locationDelegate?.phoenixLocation?(self, didFailMonitoringGeofence: geofence)
    }
    
    func didStopMonitoringGeofence(geofence:Geofence) {
        self.locationDelegate?.phoenixLocation?(self, didStopMonitoringGeofence: geofence)
    }

}