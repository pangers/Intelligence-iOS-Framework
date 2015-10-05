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
        internal static let OperationSystemVersionKey = "OperatingSystem"
        internal static let MetadataTimestampKey = "Timestamp"
        
        /// Type of Event we are trying to log.
        internal var eventType: String
        /// Value related to this EventType. Defaults to zero.
        internal var value: Double
        /// Optional identifier related to this EventType. Defaults to nil.
        internal var targetId: String?
        /// Optional metadata values associated to this EventType.
        internal var metadata: [String: AnyObject]?
        /// Prepopulated date.
        internal var eventDate: String
        
        /// Initializer for Event class.
        /// - parameter type:     Type of Event we are trying to track.
        /// - parameter value:    Value associated with Event. Defaults to 0.0.
        /// - parameter targetId: Optional identifier relevant to this event. Defaults to nil.
        /// - parameter metadata: Optional metadata field.
        /// - returns: Returns an Event object.
        /// - seealso: Analytics module `track(event:)` method.
        @objc public init(withType type: String, value: Double = 0.0, targetId: String? = nil, metadata: [String: AnyObject]? = nil) {
            self.eventType = type
            self.value = value
            self.targetId = targetId
            self.eventDate = RFC3339DateFormatter.stringFromDate(NSDate())
            self.metadata = metadata
        }
        
        /// Convert Event object to JSON representation.
        /// - returns: JSON Dictionary representation of this Event.
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