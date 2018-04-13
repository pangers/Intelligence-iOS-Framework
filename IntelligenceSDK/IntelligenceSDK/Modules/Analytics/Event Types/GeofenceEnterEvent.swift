//
//  GeofenceEnterEvent.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 20/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Event that gets fired when a monitored geofence is entered.
class GeofenceEnterEvent: Event {

    static let EventType = "Phoenix.Location.Geofence.Entered"

    init(geofence: Geofence) {
        super.init(withType: GeofenceEnterEvent.EventType, value: 0, targetId: String(geofence.id), metadata: nil)
    }

}
