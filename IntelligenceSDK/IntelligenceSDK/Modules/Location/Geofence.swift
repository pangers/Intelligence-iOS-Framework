//
//  Geofence.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// An instance of a geofence with a latitude/longitude/radius combination.
@objc(INTGeofence) public final class Geofence: NSObject {
    
    /// Longitude of the geofence.
    @objc internal(set) public var longitude: Double = 0.0
    
    /// Latitude of the geofence.
    @objc internal(set) public var latitude: Double = 0.0
    
    /// Radius around the longitude + latitude to include.
    @objc internal(set) public var radius: Double = 0.0
    
    /// Identifier of this geofence.
    @objc internal(set) public var id = 0
    
    /// Project ID for this geofence.
    @objc internal(set) public var projectId = 0
    
    /// Name of this geofence.
    @objc internal(set) public var name = ""
    
    /// Address associated with this geofence.
    @objc internal(set) public var address = ""
    
    /// Date this geofence was modified last on the server. (Unused)
    @objc internal(set) public var modifyDate: TimeInterval = 0.0
    
    /// Date this geofence was created on the server. (Unused)
    @objc  internal(set) public var createDate: TimeInterval = 0.0
    
    // Equatable
    @objc override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Geofence else {
            return false
        }
        return self.id == object.id
    }
}
