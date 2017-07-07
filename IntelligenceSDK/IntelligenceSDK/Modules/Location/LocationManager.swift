//
//  LocationManagerDelegate.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import CoreLocation

protocol LocationManagerDelegate {

    func didEnterGeofence(geofence:Geofence, withUserCoordinate:Coordinate?)
    
    func didExitGeofence(geofence:Geofence, withUserCoordinate:Coordinate?)
    
    func didUpdateLocationWithCoordinate(coordinate:Coordinate)
    
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
    
    - returns: The intelligence location manager
    */
    init(locationManager:CLLocationManager){
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self;
    }
    
    /**
    Initializes an intelligence location manager with a newly created CLLocationManager.
    
    - returns: The intelligence location manager
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
    var userLocation: Coordinate? {
        guard let coordinate = locationManager.location?.coordinate else {
            return nil
        }
        return Coordinate(withLatitude: coordinate.latitude, longitude: coordinate.longitude)
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
            
            // take a look at : https://tigerspike.atlassian.net/browse/INT-968
            // and https://tigerspike.atlassian.net/browse/INT-967
            let radius = $0.radius >= 100 ? $0.radius : 100
            
            let region = CLCircularRegion(
                center: CLLocationCoordinate2DMake($0.latitude, $0.longitude),
                radius: radius,
                identifier: $0.id.description)
            
            self?.locationManager.startMonitoring(for: region)
        }
    }
    
    /**
    Stops monitoring all geofences being monitored in the given location manager.
    */
    func stopMonitoringGeofences() {
        // Stop monitoring any regions we may be currently monitoring (such as old geofences).
        locationManager.monitoredRegions.forEachInMainThread() { [weak self] in
            self?.locationManager.stopMonitoring(for: $0)
            
            if let geofence = self?.geofenceFromRegion(region: $0) {
                self?.delegate?.didStopMonitoringGeofence(geofence: geofence)
            }
        }
        
        geofencesMonitored = nil
    }
    
    func isMonitoringGeofences() -> Bool {
        return (geofencesMonitored ?? []).count > 0
    }
    
    // MARK:- CLLocationManagerDelegate
    
    /// Called when authorization status changes, refresh our geofences states.
    /// - parameter manager: CLLocationManager instance.
    /// - parameter status:  In response to user enabling/disabling location services.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let geofences = geofencesMonitored else {
            return
        }
        startMonitoringGeofences(geofences: geofences)
    }
    
    func setLocationAccuracy(accuracy:CLLocationAccuracy) {
        self.locationManager.desiredAccuracy = accuracy
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let coordinate = Coordinate(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.delegate?.didUpdateLocationWithCoordinate(coordinate: coordinate)
    }
    
    /// Called when a geofence is entered.
    /// - parameter manager: CLLocationManager instance.
    /// - parameter region:  CLRegion we just entered.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let geofence = geofenceFromRegion(region: region) else {
            return
        }
        
        self.delegate?.didEnterGeofence(geofence: geofence, withUserCoordinate: self.userLocation)
    }
    
    /// Called when a geofence is exited.
    /// - parameter manager: CLLocationManager instance.
    /// - parameter region:  CLRegion we just exited.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let geofence = geofenceFromRegion(region: region) else {
            return
        }
        
        self.delegate?.didExitGeofence(geofence: geofence, withUserCoordinate: self.userLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        guard let geofence = geofenceFromRegion(region: region) else {
            return
        }
        
        self.delegate?.didStartMonitoringGeofence(geofence: geofence)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        guard let region = region,
            let geofence = geofenceFromRegion(region: region) else {
                return
        }
        
        self.delegate?.didFailMonitoringGeofence(geofence: geofence)
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
