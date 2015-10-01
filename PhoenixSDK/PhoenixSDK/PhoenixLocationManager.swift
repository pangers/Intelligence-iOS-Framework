//
//  LocationManagerDelegate.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import CoreLocation

protocol PhoenixLocationManagerDelegate {

    func didEnterGeofence(geofence:Geofence, withUserCoordinate:PhoenixCoordinate?)
    
    func didExitGeofence(geofence:Geofence, withUserCoordinate:PhoenixCoordinate?)
    
}

internal class PhoenixLocationManager: NSObject, CLLocationManagerDelegate {
    
    /// The location manager to use.
    private let locationManager: CLLocationManager
    
    /// The delegate that will be notified of entering/leaving geofences.
    internal var delegate:PhoenixLocationManagerDelegate?
    
    /// List of geofences monitored.
    private var geofencesMonitored:[Geofence]?
    
    /**
    Initializes the location manager with the provided CLLocationManager
    
    - parameter locationManager: the CLLocationManager to use.
    
    - returns: The phoenix location manager
    */
    init(locationManager:CLLocationManager){
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self;
    }
    
    /**
    Initializes a phoenix location manager with a newly created CLLocationManager.
    
    - returns: The phoenix location manager
    */
    override convenience init() {
        self.init(locationManager: CLLocationManager())
        // set a default accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    /**
    Starts monitoring the location of the user
    */
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    /**
    Stops monitoring the user location.
    */
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Determines if user has allowed us access.
    var hasLocationServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled() &&
            CLLocationManager.authorizationStatus() != .Restricted &&
            CLLocationManager.authorizationStatus() != .Denied
    }
    
    /// Determines if developer has requested the region monitoring permission and user has accepted.
    var hasRegionMonitoringEnabled: Bool {
        return CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self)
    }
    
    /// Returns current location if available.
    var userLocation: PhoenixCoordinate? {
        guard let coordinate = locationManager.location?.coordinate else {
            return nil
        }
        return PhoenixCoordinate(withLatitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    // MARK:- Monitoring
    
    /**
    Starts monitoring the passed geofences.
    Will stop any other monitoring going on.
    
    - parameter geofences: The geofences to monitor.
    */
    func startMonitoringGeofences(geofences:[Geofence]) {
        stopMonitoringGeofences()

        if hasRegionMonitoringEnabled {
            // Start monitoring our new geofences array.
            geofences.forEach({
                let region = CLCircularRegion(
                    center: CLLocationCoordinate2DMake($0.latitude, $0.longitude),
                    radius: $0.radius,
                    identifier: $0.id.description)
                
                locationManager.startMonitoringForRegion(region)
            })
        }
    }
    
    /**
    Stops monitoring all geofences being monitored in the given location manager.
    */
    func stopMonitoringGeofences() {
        // Stop monitoring any regions we may be currently monitoring (such as old geofences).
        locationManager.monitoredRegions.forEach({
            self.locationManager.stopMonitoringForRegion($0)
        })
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
        guard let geofence = geofenceFromRegion(region) else {
            return
        }
        
        switch state {
        case .Inside:
            self.delegate?.didEnterGeofence(geofence, withUserCoordinate: self.userLocation)
        case .Outside:
            self.delegate?.didExitGeofence(geofence, withUserCoordinate: self.userLocation)
        default:
            break
        }
    }
    
    /// Called when a geofence is entered.
    /// - parameter manager: CLLocationManager instance.
    /// - parameter region:  CLRegion we just entered.
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let geofence = geofenceFromRegion(region) else {
            return
        }

        self.delegate?.didEnterGeofence(geofence, withUserCoordinate: self.userLocation)
    }
    
    /// Called when a geofence is exited.
    /// - parameter manager: CLLocationManager instance.
    /// - parameter region:  CLRegion we just exited.
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let geofence = geofenceFromRegion(region) else {
            return
        }

        self.delegate?.didExitGeofence(geofence, withUserCoordinate: self.userLocation)
    }
    
    // MARK:- Helper methods
    
    /// Returns relevant geofence for a region or nil.
    /// - parameter region: Region to compare id with geofence array.
    /// - returns: An optional Geofence from geofences array.
    private func geofenceFromRegion(region: CLRegion) -> Geofence? {
        return self.geofencesMonitored?.filter {
            $0.id.description == region.identifier
            }.first
    }
}
