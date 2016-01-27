//
//  LocationModule.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

/// A generic DownloadGeofencesCallback in which error will be populated if something went wrong, geofences will be empty if no geofences exist (or error occurs).
public typealias DownloadGeofencesCallback = (geofences: [Geofence]?, error:NSError?) -> Void

func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
    return lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
}

/**
Implement the LocationModuleDelegate in order to be notified of events that
occur related to the location module.
*/
@objc(PHXLocationModuleDelegate)
public protocol LocationModuleDelegate {
    
    /**
    Called when the user enters into a monitored geofence.
    
    - parameter location: The location module.
    - parameter geofence: The geofence that was entered.
    */
    optional func phoenixLocation(location: LocationModuleProtocol, didEnterGeofence geofence: Geofence)
    
    /**
    Called when the user exits a monitored geofence.
    
    - parameter location: The location module.
    - parameter geofence: The geofence that was exited.
    */
    optional func phoenixLocation(location: LocationModuleProtocol, didExitGeofence geofence: Geofence)
    
    /**
    Called when the a geofence has successfully started its monitoring.
    
    - parameter location: The location module.
    - parameter geofence: The geofence that started the monitoring.
    */
    optional func phoenixLocation(location: LocationModuleProtocol, didStartMonitoringGeofence: Geofence)
    
    /**
    Called when an error occured while we tried to start monitoring a geofence. This is likely to
    be either that you passed the limit of geofences to monitor, or that the user has not granted
    location permissions for your app.
    
    - parameter location: The location module.
    - parameter geofence: The geofence that failed to be monitored.
    */
    optional func phoenixLocation(location: LocationModuleProtocol, didFailMonitoringGeofence: Geofence)
    
    /**
    Called when a geofence is no longer monitored.
    
    - parameter location: The location module.
    - parameter geofence: The geofence that stopped being monitored
    */
    optional func phoenixLocation(location: LocationModuleProtocol, didStopMonitoringGeofence: Geofence)
}

/**
The Phoenix Location module protocol. Provides geofence downloading and tracking functionality.
*/
@objc(PHXLocationModuleProtocol)
public protocol LocationModuleProtocol : ModuleProtocol {
    
    /**
    Downloads a list of geofences using the given query details. Can return an DownloadGeofencesError with LocationError.domain as domain
    
    - parameter queryDetails: The geofence query to retrieve.
    - parameter callback:     The callback that will be notified upon success/error.
    The callback receives either an array of geofences or an NSError. Apart from generic errors, the NSError can
    have as errorcode DownloadGeofencesError (6001) and as domain LocationError.domain ("LocationError").
    */
    func downloadGeofences(queryDetails: GeofenceQuery, callback: DownloadGeofencesCallback?)
    
    /**
    - returns: True if there are geofences being currently monitored.
    */
    func isMonitoringGeofences() -> Bool
    
    /**
    Starts monitoring the given geofences.
    
    - parameter geofences: The geofences to monitor. If an error occurs during the monitoring,
    the locationDelegate will be notified asynchronously.
    
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
    var locationDelegate:LocationModuleDelegate? { get set }
    
}

/// Phoenix coordinate object. CLLocationCoordinate2D can't be used as an optional.
/// Furthermore, not providing a custom location object would force the developers to
/// always require CoreLocation even if they don't need to use it.
@objc(PHXCoordinate)
public class Coordinate : NSObject {
    
    let longitude:Double
    let latitude:Double
    
    /**
    Default initializer with latitude and longitude
    
    - parameter latitude
    - parameter longitude
    
    - returns: A newly initialized geofence.
    */
    public init(withLatitude latitude:Double, longitude:Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        return self == (object as? Coordinate)
    }
}

/// Location module that is responsible for managing Geofences and User Location.
internal final class LocationModule: PhoenixModule, LocationModuleProtocol, LocationManagerDelegate, LocationModuleProvider {
    
    /// The last coordinate we received.
    private var lastLocation: Coordinate?
    
    var locationDelegate: LocationModuleDelegate?
    
    /// A reference to the analytics module so we can track the geofences entered/exited events
    internal weak var analytics: AnalyticsModuleProtocol?
    
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
    private let locationManager:LocationManager
    
    var userLocation:Coordinate? {
        return locationManager.userLocation
    }
    
    /// Default initializer. Requires a network and configuration class and a geofence enter/exit callback.
    /// - parameter delegate:         Internal delegate that notifies Phoenix.
    /// - parameter network:          Instance of Network class to use.
    /// - parameter configuration:    Configuration used to configure requests.
    /// - parameter locationManager:  Location manager used for tracking.
    /// - returns: Returns a Location object.
    internal init(
        withDelegate delegate: PhoenixInternalDelegate,
        network:Network,
        configuration: Phoenix.Configuration,
        locationManager:LocationManager)
    {
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
    
    func downloadGeofences(queryDetails: GeofenceQuery, callback: DownloadGeofencesCallback?) {
        let operation = DownloadGeofencesRequestOperation(oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, query:queryDetails, callback: { (returnedOperation) in
            let downloadGeofencesOperation = returnedOperation as! DownloadGeofencesRequestOperation
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
    
    /**
    Tracks via the analytics module that a geofence has been entered
    - parameter geofence: The geofence entered
    */
    func trackGeofenceEntered(geofence:Geofence) {
        let geofenceEvent = GeofenceEnterEvent(geofence: geofence)
        analytics?.track(geofenceEvent)
    }
    
    /**
    Tracks via the analytics module that a geofence has been exited
    - parameter geofence: The geofence exited
    */
    func trackGeofenceExited(geofence:Geofence) {
        let geofenceEvent = GeofenceExitEvent(geofence: geofence)
        analytics?.track(geofenceEvent)
    }
    
    // MARK:- LocationManagerDelegate
    
    func didEnterGeofence(geofence: Geofence, withUserCoordinate: Coordinate?) {
        self.locationDelegate?.phoenixLocation?(self, didEnterGeofence: geofence)
        self.enteredGeofences[geofence.id] = geofence
        self.trackGeofenceEntered(geofence)
    }
    
    func didExitGeofence(geofence: Geofence, withUserCoordinate: Coordinate?) {
        self.locationDelegate?.phoenixLocation?(self, didExitGeofence: geofence)
        self.enteredGeofences[geofence.id] = nil
        self.trackGeofenceExited(geofence)
    }
    
    func didUpdateLocationWithCoordinate(coordinate:Coordinate) {
        
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