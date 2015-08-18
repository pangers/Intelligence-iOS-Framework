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
        
        /// Type of Event we are trying to log.
        var eventType: String
        /// Optional value related to this EventType.
        var value: Double
        /// Optional identifier related to this EventType.
        var targetId: Int?
        /// Optional metadata values associated to this EventType.
        var metadata: NSDictionary?
        /// Geolocation stored on initialization or toJSON.
        private var geolocation: CLLocationCoordinate2D?
        
        init(withType type: String, value: Double = 0.0, targetId: Int? = nil, metadata: NSDictionary? = nil) {
            self.eventType = type
            self.value = value
            self.targetId = targetId
            self.metadata = metadata
            self.geolocation = Phoenix.Location.lastKnownLocation()
        }
        
        internal func toJSON() -> JSONDictionary {
            
            // Set geolocation if we were not able to last time.
            if geolocation == nil {
                geolocation = Phoenix.Location.lastKnownLocation()
            }
            
            var dictionary: [String: AnyObject] = [Event.EventTypeKey: eventType, Event.EventValueKey: value]
            
            // Set keys with optional values.
            dictionary <-? (Event.TargetIdKey, targetId)
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

/*

[
{
"EventType": "Phoenix.Syndicate.Article.Viewed",
"EventValue": 1,
"TargetId": "21", /* relates to the event, so in this case it's the article Id */
"PhoenixIdentity_UserId":85215,
"Geolocation": {
"Latitude": 37.332331,
"Longitude": -122.031219
},
"Metadata": {
"param 1": "value 1",
"param 2": "value 2"
}, /* metadata is optional */
"IpAddress": "220.233.135.192",
"PhoenixIdentity_InstallationId":"38B8296C-6B2E-4CEB-B9E0-CC2330158075",
"PhoenixIdentity_ApplicationId":12,
"ApplicationVersion":"0.1",
"DeviceType":"Nexus 7",
"OperatingSystem":"Android 5.0.2"
}
]*/
