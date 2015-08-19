//
//  PhoenixAnalytics.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 18/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

@objc public protocol PhoenixAnalytics {
    
    func track(event:Phoenix.Event)
    
}


internal extension Phoenix {
    internal final class Analytics: PhoenixAnalytics, PhoenixModuleProtocol {
        
        private let configuration: Configuration
        private let installationStorage: PhoenixInstallationStorageProtocol
        private let applicationVersion: PhoenixApplicationVersionProtocol
        private let network: Network
        private var eventQueue: PhoenixEventQueue?
        
        init(withNetwork network: Network, configuration: Configuration, installationStorage: PhoenixInstallationStorageProtocol, applicationVersion: PhoenixApplicationVersionProtocol) {
            self.network = network
            self.configuration = configuration
            self.installationStorage = installationStorage
            self.applicationVersion = applicationVersion
        }
        
        internal func startup() {
            eventQueue = PhoenixEventQueue(withCallback: sendEvents)
            eventQueue?.startQueue()
            // Track application opened.
            trackApplicationOpened()
        }
        
        /// Terminate this module. Must call startup in order to resume, should only occur on SDK shutdown.
        internal func shutdown() {
            eventQueue?.stopQueue()
        }
        
        /// Track user engagement and behavioral insight.
        /// - parameter event: Event containing information to track.
        @objc func track(event: Phoenix.Event) {
            eventQueue?.enqueueEvent(prepareEvent(event))
        }
        
        /// Track application open event (internally managed event).
        internal func trackApplicationOpened() {
            // TODO: Revise fields once we get a response about what is required.
            eventQueue?.enqueueEvent(prepareEvent(Phoenix.OpenApplicationEvent()))
        }
        
        /// Track geofence entered event (internally managed event).
        internal func trackGeofenceEnteredEvent(geofence: Geofence) {
            // stub
            // TODO: Implement
        }
        
        /// Track geofence exited event (internally managed event).
        internal func trackGeofenceExitedEvent(geofence: Geofence) {
            // stub
            // TODO: Implement
        }
        
        /// Add automatically populated fields to dictionary.
        /// - parameter event: Event to prepare for sending.
        /// - returns: JSONDictionary representation of Event including populated fields.
        internal func prepareEvent(event: Event) -> JSONDictionary {
            var dictionary = event.toJSON()

            // FIXME: Are these fields correct? Using postman example...
            dictionary[Event.ApplicationIdKey] = configuration.applicationID
            dictionary[Event.DeviceTypeKey] = UIDevice.currentDevice().model
            dictionary[Event.OperationSystemVersionKey] = UIDevice.currentDevice().systemVersion
            
            // Set optional values (may fail for whatever reason).
            dictionary <-? (Event.ApplicationVersionKey, applicationVersion.phx_applicationVersionString)
            dictionary <-? (Event.InstallationIdKey, installationStorage.phx_installationID)
            
            // TODO: UserId
            
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
