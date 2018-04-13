//
//  IntelligenceEvent.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 18/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

/// Custom event which can be sent to the 'track:' method in the Analytics module.
@objc(INTEvent)
public class Event: NSObject {
    static let EventTypeKey = "EventType"
    static let EventValueKey = "EventValue"
    static let EventDateKey = "EventDate"
    static let TargetIdKey = "TargetId"
    static let UserIdKey = "PhoenixIdentity_UserId"
    static let GeolocationKey = "Geolocation"
    static let GeolocationLatitudeKey = "Latitude"
    static let GeolocationLongitudeKey = "Longitude"
    static let MetadataKey = "Metadata"
    static let InstallationIdKey = "PhoenixIdentity_InstallationId"
    static let ApplicationIdKey = "PhoenixIdentity_ApplicationId"
    static let ApplicationVersionKey = "ApplicationVersion"
    static let ProjectIdKey = "ProjectId"
    static let DeviceTypeKey = "DeviceType"
    static let OperationSystemVersionKey = "OperatingSystemVersion"
    static let DeviceIDKey = "DeviceID"
    static let Platform = "platform"

    /// Type of Event we are trying to log.
    var eventType: String
    /// Value related to this EventType. Defaults to zero.
    var value: Double
    /// Optional identifier related to this EventType. Defaults to nil.
    var targetId: String?
    /// Optional metadata values associated to this EventType.
    var metadata: [String: AnyObject]?
    /// Prepopulated date.
    var eventDate: String

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
        self.eventDate = RFC3339DateFormatter.string(from: Date())

        if nil == metadata {
            var data: [String: AnyObject] = [:]
            data[Event.Platform] = UIDevice.platform as AnyObject
            self.metadata = data
        } else {
            if var data = metadata {
                data[Event.Platform] = UIDevice.platform as AnyObject
                self.metadata = data
            }
        }
    }

    /// Convert Event object to JSON representation.
    /// - returns: JSON Dictionary representation of this Event.
    func toJSON() -> JSONDictionary {
        var dictionary: [String: Any] = [Event.EventTypeKey: eventType, Event.EventValueKey: value, Event.EventDateKey: eventDate]

        // Set keys with optional values.
        dictionary <-? (Event.TargetIdKey, targetId)
        dictionary <-? (Event.MetadataKey, metadata)

        return dictionary
    }

    override public var description: String {
        return String(format: "EventName : %@, Event Value : %f, MetaData : %@", self.eventType, self.value, self.metadata ?? "Empty meta data..." )
    }

}
