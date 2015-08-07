//
//  Geofence.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

protocol GeofenceProtocol {
    /// Longitude of the geofence.
    var longitude: Double { get set }
    /// Latitude of the geofence.
    var latitude: Double { get set }
    /// Identifier of this geofence.
    var id: Int { get set }
    /// Project ID for this geofence.
    var projectId: Int { get set }
    /// Name of this geofence.
    var name: String { get set }
    /// Address associated with this geofence.
    var address: String { get set }
    /// Date this geofence was modified last on the server. (Unused)
    var modifyDate: NSTimeInterval { get set }
    /// Date this geofence was created on the server. (Unused)
    var createDate: NSTimeInterval { get set }
    /// Radius around the longitude + latitude to include.
    var radius: Double { get set }
}

/// An instance of a geofence with a latitude/longitude/radius combination.
internal final class Geofence: GeofenceProtocol {
    var longitude = 0.0
    var latitude = 0.0
    var id = 0
    var projectId = 0
    var name = ""
    var address = ""
    var modifyDate = 0.0
    var createDate = 0.0
    var radius = 0.0
}
