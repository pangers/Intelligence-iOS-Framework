//
//  LocationModule.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

/// A generic DownloadGeofencesCallback in which error will be populated if something went wrong, geofences will be empty if no geofences exist (or error occurs).
public typealias DownloadGeofencesCallback = ([Geofence]?, NSError?) -> Void

func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
    return lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
}

/**
Implement the LocationModuleDelegate in order to be notified of events that
occur related to the location module.
*/
@objc(INTLocationModuleDelegate)
public protocol LocationModuleDelegate {
    
    /**
    Called when the user enters into a monitored geofence.
    
    - parameter location: The location module.
    - parameter geofence: The geofence that was entered.
    */
    @objc optional func intelligenceLocation(location: LocationModuleProtocol, didEnterGeofence geofence: Geofence)
    
    /**
    Called when the user exits a monitored geofence.
    
    - parameter location: The location module.
    - parameter geofence: The geofence that was exited.
    */
    @objc optional func intelligenceLocation(location: LocationModuleProtocol, didExitGeofence geofence: Geofence)
    
    /**
    Called when the a geofence has successfully started its monitoring.
    
    - parameter location: The location module.
    - parameter geofence: The geofence that started the monitoring.
    */
    @objc optional func intelligenceLocation(location: LocationModuleProtocol, didStartMonitoringGeofence: Geofence)
    
    /**
    Called when an error occured while we tried to start monitoring a geofence. This is likely to
    be either that you passed the limit of geofences to monitor, or that the user has not granted
    location permissions for your app.
    
    - parameter location: The location module.
    - parameter geofence: The geofence that failed to be monitored.
    */
    @objc optional func intelligenceLocation(location: LocationModuleProtocol, didFailMonitoringGeofence: Geofence)
    
    /**
    Called when a geofence is no longer monitored.
    
    - parameter location: The location module.
    - parameter geofence: The geofence that stopped being monitored
    */
    @objc optional func intelligenceLocation(location: LocationModuleProtocol, didStopMonitoringGeofence: Geofence)
}

/**
The Intelligence Location module protocol. Provides geofence downloading and tracking functionality.
*/
@objc(INTLocationModuleProtocol)
public protocol LocationModuleProtocol : ModuleProtocol {
    
    /**
    Downloads a list of geofences using the given query details.
    
    - parameter queryDetails: The geofence query to retrieve.
    - parameter callback:     The callback that will be notified upon success/error.
    The callback receives either an array of geofences or an NSError.
    */
    @objc(downloadGeofences:callback:)
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
    @objc(startMonitoringGeofences:)
    func startMonitoringGeofences(geofences:[Geofence])
    
    /**
    Stops monitoring the geofences, and flushes the ones the location module keeps.
    */
    func stopMonitoringGeofences()
    
    /**
    Sets the location accuracy to use when monitoring regions. Defaults to kCLLocationAccuracyHundredMeters.
    
    - parameter accuracy: The accuracy
    */
    @objc(setLocationAccuracy:)
    func setLocationAccuracy(accuracy:CLLocationAccuracy)
    
    /// Geofences array, loaded from Cache on startup but updated with data from server if network is available.
    /// When updated it will set the location manager to monitor the given geofences if we have permissions.
    /// If we don't have permissions it will do nothing, and if we don't receive any geofence, we will
    /// stop monitoring the previous geofences.
    /// As a result, this holds the list of geofences that are currently monitored if we have permissions.
    var geofences: [Geofence]? { get }
    
    /// The delegate that will be notified upon entering/exiting a geofence.
    var locationDelegate:LocationModuleDelegate? { get set }
    
    /// set this property to true if you want to include location in all of your intelligence events. default value is
    /// false. location permissions are required to granted before this property is used which is the caller's
    /// responsibility. for more information, read the documentation.
    @objc var includeLocationInEvents: Bool { get set }
}

/// Intelligence coordinate object. CLLocationCoordinate2D can't be used as an optional.
/// Furthermore, not providing a custom location object would force the developers to
/// always require CoreLocation even if they don't need to use it.
@objc(INTCoordinate)
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
    
    public override func isEqual(_ object: Any?) -> Bool {
        return self == (object as? Coordinate)
    }
}

/// Location module that is responsible for managing Geofences and User Location.
internal final class LocationModule: IntelligenceModule, LocationModuleProtocol, LocationManagerDelegate, LocationModuleProvider {
    
    /// The last coordinate we received.
    private var lastLocation: Coordinate?
    
    var locationDelegate: LocationModuleDelegate?
    
    var includeLocationInEvents: Bool = false {
        didSet {
            if includeLocationInEvents {
                self.startMonitoringLocation()
            } else {
                self.stopMonitoringLocation()
            }
        }
    }
    
    /// A reference to the analytics module so we can track the geofences entered/exited events
    internal weak var analytics: AnalyticsModuleProtocol?
    
    /// Array of recently entered geofences, on exit they will be removed, ensures no duplicate API calls on reload/download of geofences.
    internal lazy var enteredGeofences = [Int:Geofence]()
    
    internal var geofences: [Geofence]? {
        didSet {
            guard let geofences = geofences, geofences.count > 0 else {
                self.locationManager.stopMonitoringGeofences()
                return
            }
            
            self.locationManager.startMonitoringGeofences(geofences: geofences)
        }
    }
    
    /// The location manager
    private let locationManager:LocationManager
    
    var userLocation:Coordinate? {
        return locationManager.userLocation
    }
    
    /// Default initializer. Requires a network and configuration class and a geofence enter/exit callback.
    /// - parameter delegate:         Internal delegate that notifies Intelligence.
    /// - parameter network:          Instance of Network class to use.
    /// - parameter configuration:    Configuration used to configure requests.
    /// - parameter locationManager:  Location manager used for tracking.
    /// - returns: Returns a Location object.
    internal init(
        withDelegate delegate: IntelligenceInternalDelegate,
        network:Network,
        configuration: Intelligence.Configuration,
        locationManager:LocationManager)
    {
        self.locationManager = locationManager
        super.init(withDelegate:delegate, network: network, configuration: configuration)
        self.locationManager.delegate = self
        
        // Initialize the last known location with the user's one.
        lastLocation = userLocation
    }
    
    // MARK:- Startup and shutdown methods.
    override func startup(completion: @escaping (Bool) -> ()) {
        sharedIntelligenceLogger.log(message:"Location module startup....");
        super.startup(completion: completion)
        sharedIntelligenceLogger.log(message:"Location module start success*****");
    }
    
    /**
    Stops monitoring and nils the geofences.
    */
    override func shutdown() {
        // Clear geofences.
        geofences = nil
      
        sharedIntelligenceLogger.log(message:"Location Module Shutdown");

        super.shutdown()
    }
    
    // MARK:- Download geofences
    
    func downloadGeofences(queryDetails: GeofenceQuery, callback: DownloadGeofencesCallback?) {
        
        sharedIntelligenceLogger.log(message:"Downloading of geofenses");
        
        let operation = DownloadGeofencesRequestOperation(oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, query:queryDetails, callback: { (returnedOperation) in
            let downloadGeofencesOperation = returnedOperation as! DownloadGeofencesRequestOperation
            let error = downloadGeofencesOperation.output?.error
            let geofences = downloadGeofencesOperation.geofences
            callback?(geofences, error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    func isMonitoringGeofences() -> Bool {
        return self.locationManager.isMonitoringGeofences()
    }
    
    func startMonitoringGeofences(geofences:[Geofence]) {
        sharedIntelligenceLogger.log(message: "Start Monitoring Geofences")
        self.locationManager.startMonitoringGeofences(geofences: geofences)
    }
    
    func stopMonitoringGeofences() {
        sharedIntelligenceLogger.log(message: "Stop Monitoring Geofences")
        self.locationManager.stopMonitoringGeofences()
    }
    
    func setLocationAccuracy(accuracy:CLLocationAccuracy) {
        self.locationManager.setLocationAccuracy(accuracy: accuracy)
    }
    
    
    internal func startMonitoringLocation() {
        sharedIntelligenceLogger.log(message: "Start monitoring location")
        self.locationManager.startUpdatingLocation()
    }
    
    internal func stopMonitoringLocation() {
        sharedIntelligenceLogger.log(message: "Stop monitoring location")
        self.locationManager.stopUpdatingLocation()
    }
    
    /**
    Tracks via the analytics module that a geofence has been entered
    - parameter geofence: The geofence entered
    */
    func trackGeofenceEntered(geofence:Geofence) {
        let geofenceEvent = GeofenceEnterEvent(geofence: geofence)
        analytics?.track(event: geofenceEvent)
    }
    
    /**
    Tracks via the analytics module that a geofence has been exited
    - parameter geofence: The geofence exited
    */
    func trackGeofenceExited(geofence:Geofence) {
        let geofenceEvent = GeofenceExitEvent(geofence: geofence)
        analytics?.track(event: geofenceEvent)
    }
    
    // MARK:- LocationManagerDelegate
    
    func didEnterGeofence(geofence: Geofence, withUserCoordinate: Coordinate?) {
        sharedIntelligenceLogger.log(message: "Did enter geofence")
        self.locationDelegate?.intelligenceLocation?(location: self, didEnterGeofence: geofence)
        self.enteredGeofences[geofence.id] = geofence
        self.trackGeofenceEntered(geofence: geofence)
    }
    
    func didExitGeofence(geofence: Geofence, withUserCoordinate: Coordinate?) {
        sharedIntelligenceLogger.log(message: "Did exit geofence")
        self.locationDelegate?.intelligenceLocation?(location: self, didExitGeofence: geofence)
        self.enteredGeofences[geofence.id] = nil
        self.trackGeofenceExited(geofence: geofence)
    }
    
    func didUpdateLocationWithCoordinate(coordinate:Coordinate) {
        sharedIntelligenceLogger.log(message: "Did update geofence location")
    }
    
    func didStartMonitoringGeofence(geofence:Geofence) {
        sharedIntelligenceLogger.log(message: "Did start monitor geofense")
        self.locationDelegate?.intelligenceLocation?(location: self, didStartMonitoringGeofence: geofence)
    }
    
    func didFailMonitoringGeofence(geofence:Geofence) {
        sharedIntelligenceLogger.log(message: "Did fail monitor geofense")
        self.locationDelegate?.intelligenceLocation?(location: self, didFailMonitoringGeofence: geofence)
    }
    
    func didStopMonitoringGeofence(geofence:Geofence) {
        sharedIntelligenceLogger.log(message: "Did stop monitor geofense")
        self.locationDelegate?.intelligenceLocation?(location: self, didStopMonitoringGeofence: geofence)
    }

}
