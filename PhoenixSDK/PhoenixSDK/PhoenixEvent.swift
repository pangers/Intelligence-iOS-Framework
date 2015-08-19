//
//  PhoenixEvent.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 18/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

public extension Phoenix {
    @objc(PHXEvent)
    public class Event: NSObject {
        // TODO: Ensure these keys are correct.
        internal static let EventTypeKey = "EventType"
        internal static let EventValueKey = "EventValue"
        internal static let TargetIdKey = "TargetId"
        internal static let UserIdKey = "PhoenixIdentity_UserId"
        internal static let GeolocationKey = "Geolocation"
        internal static let GeolocationLatitudeKey = "Latitude"
        internal static let GeolocationLongitudeKey = "Longitude"
        internal static let MetadataKey = "Metadata"
        internal static let InstallationIdKey = "PhoenixIdentity_InstallationId"
        internal static let ApplicationIdKey = "PhoenixIdentity_ApplicationId"
        internal static let ApplicationVersionKey = "ApplicationVersion"
        internal static let DeviceTypeKey = "DeviceType"
        internal static let OperationSystemVersionKey = "OperatingSystemVersion"
        internal static let MetadataTimestampKey = "Timestamp"
        
        /// Type of Event we are trying to log.
        var eventType: String
        /// Optional value related to this EventType.
        var value: Double
        /// Optional identifier related to this EventType.
        var targetId: Int
        /// Optional metadata values associated to this EventType.
        var metadata: [String: AnyObject]?
        /// Geolocation stored on initialization or toJSON.
        private var geolocation: CLLocationCoordinate2D?
        
        @objc public init(withType type: String, value: Double = 0.0, targetId: Int = 0, metadata: [String: AnyObject]? = nil) {
            self.eventType = type
            self.value = value
            self.targetId = targetId
            self.metadata = metadata
            self.geolocation = LocationManager.sharedInstance.userLocation
        }
        
        internal func toJSON() -> JSONDictionary {
            
            // Set geolocation if we were not able to last time.
            if geolocation == nil {
                geolocation = LocationManager.sharedInstance.userLocation
            }
            
            var dictionary: [String: AnyObject] = [Event.EventTypeKey: eventType, Event.EventValueKey: value]
            
            // Set keys with optional values.
            dictionary <-? (Event.TargetIdKey, targetId)
            if metadata == nil {
                metadata = [String: AnyObject]()
            }
            // Add timestamp
            metadata?[Event.MetadataTimestampKey] = NSDate().timeIntervalSinceReferenceDate
            dictionary <-? (Event.MetadataKey, metadata)
            
            // Add geolocation
            var geoDict = JSONDictionary()
            geoDict <-? (Event.GeolocationLatitudeKey, geolocation?.latitude)
            geoDict <-? (Event.GeolocationLongitudeKey, geolocation?.longitude)
            dictionary <-? (Event.GeolocationKey, geoDict.keys.count == 2 ? geoDict : nil)

            return dictionary
        }
    }
}