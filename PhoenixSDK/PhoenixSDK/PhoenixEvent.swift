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
        internal static let EventTypeKey = "EventType"
        internal static let EventValueKey = "EventValue"
        internal static let EventDateKey = "EventDate"
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
        /// Prepopulated date.
        var eventDate: String
        
        @objc public init(withType type: String, value: Double = 0.0, targetId: Int = 0, metadata: [String: AnyObject]? = nil) {
            self.eventType = type
            self.value = value
            self.targetId = targetId
            self.metadata = metadata
            self.eventDate = IRFC3339DateFormatter.stringFromDate(NSDate())
        }
        
        internal func toJSON() -> JSONDictionary {
            var dictionary: [String: AnyObject] = [Event.EventTypeKey: eventType, Event.EventValueKey: value, Event.EventDateKey: eventDate]
            
            // Set keys with optional values.
            dictionary <-? (Event.TargetIdKey, targetId)
            if metadata == nil {
                metadata = [String: AnyObject]()
            }
            // Add timestamp
            dictionary <-? (Event.MetadataKey, metadata)

            return dictionary
        }
    }
}