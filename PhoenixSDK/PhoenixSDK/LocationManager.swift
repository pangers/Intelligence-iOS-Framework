//
//  LocationManagerDelegate.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import CoreLocation

protocol LocationManagerDelegate {

    func didEnterGeofence(geofence:Geofence, withUserCoordinate:PhoenixCoordinate?)
    
    func didExitGeofence(geofence:Geofence, withUserCoordinate:PhoenixCoordinate?)
    
    func didUpdateLocationWithCoordinate(coordinate:PhoenixCoordinate)
    
    func didStartMonitoringGeofence(geofence:Geofence)
    
    func didFailMonitoringGeofence(geofence:Geofence)
    
    func didStopMonitoringGeofence(geofence:Geofence)
}

internal class LocationManager: NSObject, CLLocationManagerDelegate {
    
    /// The location manager to use.
    private let locationManager: CLLocationManager
    
    /// The delegate that will be notified of entering/leaving geofences.
    internal var delegate: LocationManagerDelegate?
    
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
        geofencesMonitored = geofences
        
        locationManager.startUpdatingLocation()

        // Start monitoring our new geofences array.
        geofences.forEachInMainThread() { [weak self] in
            let region = CLCircularRegion(
                center: CLLocationCoordinate2DMake($0.latitude, $0.longitude),
                radius: $0.radius,
                identifier: $0.id.description)
            
            self?.locationManager.startMonitoringForRegion(region)
        }
    }
    
    /**
    Stops monitoring all geofences being monitored in the given location manager.
    */
    func stopMonitoringGeofences() {
        // Stop monitoring any regions we may be currently monitoring (such as old geofences).
        locationManager.monitoredRegions.forEachInMainThread() { [weak self] in
            self?.locationManager.stopMonitoringForRegion($0)
            
            if let geofence = self?.geofenceFromRegion($0) {
                self?.delegate?.didStopMonitoringGeofence(geofence)
            }
        }
        
        geofencesMonitored = nil
    }
    
    func isMonitoringGeofences() -> Bool {
        return geofencesMonitored?.count > 0
    }
    
    // MARK:- CLLocationManagerDelegate
    
    /// Called when authorization status changes, refresh our geofences states.
    /// - parameter manager: CLLocationManager instance.
    /// - parameter status:  In response to user enabling/disabling location services.
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard let geofences = geofencesMonitored else {
            return
        }
        startMonitoringGeofences(geofences)
    }
    
    func setLocationAccuracy(accuracy:CLLocationAccuracy) {
        self.locationManager.desiredAccuracy = accuracy
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let coordinate = PhoenixCoordinate(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.delegate?.didUpdateLocationWithCoordinate(coordinate)
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
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        guard let geofence = geofenceFromRegion(region) else {
            return
        }
        
        self.delegate?.didStartMonitoringGeofence(geofence)
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        guard let region = region,
            let geofence = geofenceFromRegion(region) else {
            return
        }
        
        self.delegate?.didFailMonitoringGeofence(geofence)
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
