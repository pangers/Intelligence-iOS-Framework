//
//  PhoenixAnalytics.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 18/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// The Phoenix Analytics Module defines the methods available for tracking events.
@objc public protocol PhoenixAnalytics {
    
    /// Track user engagement and behavioral insight.
    /// - parameter event: Event containing information to track.
    func track(event:Phoenix.Event)
    
}


internal extension Phoenix {
    
    /// The Phoenix Analytics Module defines the methods available for tracking events.
    internal final class Analytics: PhoenixAnalytics, PhoenixModuleProtocol {
        
        internal weak var phoenix: Phoenix!
        
        /// Instance of the Network class, used for sending analytical events.
        private var network: Network {
            return phoenix.network
        }
        
        /// Instance of the Configuration class, used for configuring requests.
        private var configuration: Configuration {
            return phoenix.internalConfiguration
        }
    
        /// Interrogated for 'InstallationId' to include in requests (if available).
        private var installationStorage: PhoenixInstallationStorageProtocol {
            return phoenix.installation.installationStorage
        }
        
        /// Interrogated for 'ApplicationVersion' to include in requests.
        private var applicationVersion: PhoenixApplicationVersionProtocol {
            return phoenix.installation.applicationVersion
        }
        
        /// Event queue responsible for queuing and storing events to disk.
        private var eventQueue: PhoenixEventQueue?
        
        /// Instance of location class, used for configuring requests and managing geofences.
        internal weak var location: Location?
        
        // MARK:- PhoenixModuleProtocol
        
        internal func startup() {
            eventQueue = PhoenixEventQueue(withCallback: sendEvents)
            eventQueue?.startQueue()
            // Track application opened.
            trackApplicationOpened()
        }
        
        internal func shutdown() {
            eventQueue?.stopQueue()
        }
        
        @objc func track(event: Phoenix.Event) {
            eventQueue?.enqueueEvent(prepareEvent(event))
        }
        
        // MARK: Internal
        
        /// Track application open event (internally managed).
        internal func trackApplicationOpened() {
            track(Phoenix.OpenApplicationEvent())
        }
        
        /// Track geofence events (internally managed).
        /// - parameter geofence: Geofence to track.
        /// - parameter entered:  Whether we entered or exited.
        internal func trackGeofence(geofence: Geofence, entered: Bool) {
            // TODO: Re-implement once testing is completed.
//            track(entered ?
//                GeofenceEnterEvent(geofence: geofence) :
//                GeofenceExitEvent(geofence: geofence))
        }
        
        /// Add automatically populated fields to dictionary.
        /// - parameter event: Event to prepare for sending.
        /// - returns: JSONDictionary representation of Event including populated fields.
        internal func prepareEvent(event: Event) -> JSONDictionary {
            var dictionary = event.toJSON()
            
            dictionary[Event.ApplicationIdKey] = configuration.applicationID
            dictionary[Event.DeviceTypeKey] = UIDevice.currentDevice().model
            dictionary[Event.OperationSystemVersionKey] = UIDevice.currentDevice().systemVersion
            
            // Set optional values (may fail for whatever reason).
            dictionary <-? (Event.ApplicationVersionKey, applicationVersion.phx_applicationVersionString)
            dictionary <-? (Event.InstallationIdKey, installationStorage.phx_installationID)
            // TODO: Get User ID dictionary <-? (Event.UserIdKey, network.authentication.userId)
            
            // Add geolocation
            let geolocation = location?.userLocation
            var geoDict = JSONDictionary()
            geoDict <-? (Event.GeolocationLatitudeKey, geolocation?.latitude)
            geoDict <-? (Event.GeolocationLongitudeKey, geolocation?.longitude)
            dictionary <-? (Event.GeolocationKey, geoDict.keys.count == 2 ? geoDict : nil)
            
            return dictionary
        }
        
        /// Callback from EventQueue, responsible for propogating changes to the server.
        /// - parameter events:     Array of JSONified Events to send.
        /// - parameter completion: Must be called on completion to notify caller of success/failure.
        internal func sendEvents(events: JSONDictionaryArray, completion: (error: NSError?) -> ()) {
            let operation = AnalyticsRequestOperation(json: events, oauth: phoenix.bestSDKUserOAuth, phoenix: phoenix)
            operation.completionBlock = { [weak operation] in
                completion(error: operation?.output?.error)
            }
            
            network.enqueueOperation(operation)
        }
    }
}
