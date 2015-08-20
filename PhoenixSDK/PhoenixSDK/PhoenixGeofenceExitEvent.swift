//
//  PhoenixGeofenceExitEvent.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 20/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal extension Phoenix {
    
    /// Event that gets fired when a monitored geofence is exited.
    internal class GeofenceExitEvent: Event {
        
        init(geofence: Geofence) {
            super.init(withType: "Phoenix.Location.Geofence.Exit", value: 0, targetId: geofence.id, metadata: nil)
        }
        
    }
    
}