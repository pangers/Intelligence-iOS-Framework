//
//  MockCLLocationManager.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import CoreLocation
import IntelligenceSDK

class MockCLLocationManager: CLLocationManager {
    
    var regions = Set<CLRegion>()
    
    func fireEnterGeofence(_ geofence:Geofence) {
        guard let region = regionFromGeofence(geofence) else {
            return
        }
        
        self.delegate!.locationManager!(self, didEnterRegion: region)
    }

    func fireExitGeofence(_ geofence:Geofence) {
        guard let region = regionFromGeofence(geofence) else {
            return
        }
        
        self.delegate!.locationManager!(self, didExitRegion: region)
    }

    func regionFromGeofence(_ geofence:Geofence) -> CLRegion? {
        return regions.filter { (region) -> Bool in
            return region.identifier == String(geofence.id)
        }.first
    }
    
    override func startMonitoring(for region: CLRegion) {
        regions.insert(region)
        self.delegate?.locationManager?(self, didStartMonitoringFor: region)
    }
    
    override func stopMonitoring(for region: CLRegion) {
        regions.remove(region)
    }
}
