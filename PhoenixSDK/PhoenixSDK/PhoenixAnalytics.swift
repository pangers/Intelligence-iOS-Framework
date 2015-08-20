//
//  PhoenixAnalytics.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 18/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

@objc public protocol PhoenixAnalytics {
    
    /// Track user engagement and behavioral insight.
    /// - parameter event: Event containing information to track.
    func track(event:Phoenix.Event)
    
}


internal extension Phoenix {
    internal final class Analytics: PhoenixAnalytics, PhoenixModuleProtocol {
        
        private let configuration: Configuration
        private let installationStorage: PhoenixInstallationStorageProtocol
        private let applicationVersion: PhoenixApplicationVersionProtocol
        private let network: Network
        private var eventQueue: PhoenixEventQueue?
        internal var location: Location?
        private let authentication: Authentication
        
        init(withNetwork network: Network, configuration: Configuration, installationStorage: PhoenixInstallationStorageProtocol, applicationVersion: PhoenixApplicationVersionProtocol, authentication: Authentication) {
            self.network = network
            self.configuration = configuration
            self.installationStorage = installationStorage
            self.applicationVersion = applicationVersion
            self.authentication = authentication
        }
        
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
            print("\(entered) geofence: \(geofence.id) radius: \(geofence.radius)")
            if entered {
                track(GeofenceEnterEvent(geofence: geofence))
            } else {
                track(GeofenceExitEvent(geofence: geofence))
            }
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
            dictionary <-? (Event.UserIdKey, authentication.userId)
            
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
            let operation = AnalyticsRequestOperation(withNetwork: network, configuration: configuration, eventsJSON: events) { (error) -> Void in
                completion(error: error)
            }
            network.executeNetworkOperation(operation)
        }
    }
}
