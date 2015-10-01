//
//  Geofence.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

func == (lhs: Geofence, rhs: Geofence) -> Bool {
    return lhs.id == rhs.id
}

/// An instance of a geofence with a latitude/longitude/radius combination.
@objc public final class Geofence: NSObject {
    
    /// Longitude of the geofence.
    internal(set) var longitude: Double = 0.0
    
    /// Latitude of the geofence.
    internal(set) var latitude: Double = 0.0
    
    /// Radius around the longitude + latitude to include.
    internal(set) var radius: Double = 0.0
    
    /// Identifier of this geofence.
    internal(set) var id = 0
    
    /// Project ID for this geofence.
    internal(set) var projectId = 0
    
    /// Name of this geofence.
    internal(set) var name = ""
    
    /// Address associated with this geofence.
    internal(set) var address = ""
    
    /// Date this geofence was modified last on the server. (Unused)
    internal(set) var modifyDate: NSTimeInterval = 0.0
    
    /// Date this geofence was created on the server. (Unused)
    internal(set) var createDate: NSTimeInterval = 0.0
    
    // Equatable
    override public func isEqual(object: AnyObject?) -> Bool {
        guard let object = object else {
            return false
        }
        return self.id == object.id
    }
}
