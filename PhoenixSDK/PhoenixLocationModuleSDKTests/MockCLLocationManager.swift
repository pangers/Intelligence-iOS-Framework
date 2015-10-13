//
//  MockCLLocationManager.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import CoreLocation
import PhoenixSDK

class MockCLLocationManager: CLLocationManager {
    
    var regions = Set<CLRegion>()
    
    func fireEnterGeofence(geofence:Geofence) {
        guard let region = regionFromGeofence(geofence) else {
            return
        }
        
        self.delegate!.locationManager!(self, didEnterRegion: region)
    }

    func fireExitGeofence(geofence:Geofence) {
        guard let region = regionFromGeofence(geofence) else {
            return
        }
        
        self.delegate!.locationManager!(self, didExitRegion: region)
    }

    func regionFromGeofence(geofence:Geofence) -> CLRegion? {
        return regions.filter { (region) -> Bool in
            return region.identifier == String(geofence.id)
        }.first
    }
    
    override func startMonitoringForRegion(region: CLRegion) {
        regions.insert(region)
        self.delegate?.locationManager?(self, didStartMonitoringForRegion: region)
    }
    
    override func stopMonitoringForRegion(region: CLRegion) {
        regions.remove(region)
    }
}
