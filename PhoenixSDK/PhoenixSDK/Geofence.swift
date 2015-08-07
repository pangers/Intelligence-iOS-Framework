//
//  Geofence.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

protocol GeofenceProtocol {
    var longitude: Double { get set }
    var latitude: Double { get set }
    var id: Int { get set }
    var projectId: Int { get set }
    var name: String { get set }
    var address: String { get set }
    var modifyDate: NSTimeInterval { get set }
    var createDate: NSTimeInterval { get set }
    var radius: Double { get set }
}

class Geofence: GeofenceProtocol {
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    var id: Int = 0
    var projectId: Int = 0
    var name: String = ""
    var address: String = ""
    var modifyDate: NSTimeInterval = 0.0
    var createDate: NSTimeInterval = 0.0
    var radius: Double = 0.0
}
