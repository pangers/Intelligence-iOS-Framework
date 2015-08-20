//
//  PhoenixLocationManager.swift
//  PhoenixDemo-Swift
//
//  Created by Chris Nevin on 20/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import CoreLocation

class PhoenixLocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }
    
    func requestAuthorization() {
        // Request location access.
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // Handle authorization changes in app if necessary...
        print("LocationManager - Changed authorization status: \(status)")
    }
}
