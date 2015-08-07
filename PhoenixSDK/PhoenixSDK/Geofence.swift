//
//  Geofence.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// An instance of a geofence with a latitude/longitude/radius combination.
internal final class Geofence {
    /// Longitude of the geofence.
    var longitude = 0.0
    /// Latitude of the geofence.
    var latitude = 0.0
    /// Identifier of this geofence.
    var id = 0
    /// Project ID for this geofence.
    var projectId = 0
    /// Name of this geofence.
    var name = ""
    /// Address associated with this geofence.
    var address = ""
    /// Date this geofence was modified last on the server. (Unused)
    var modifyDate = 0.0
    /// Date this geofence was created on the server. (Unused)
    var createDate = 0.0
    /// Radius around the longitude + latitude to include.
    var radius = 0.0
}
