//
//  PhoenixAnalytics.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 18/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// The Phoenix Analytics Module defines the methods available for tracking events.
@objc public protocol PhoenixAnalytics : PhoenixModuleProtocol {
    
    /// Track user engagement and behavioral insight.
    /// - parameter event: Event containing information to track.
    func track(event:Phoenix.Event)
    
	/// Track user engagement and behavioral insight.
	/// - parameter screenName: An identifier for the screen.
	/// - parameter viewingDuration: The time (in seconds) spent on the screen.
	func trackScreenViewed(screenName: String, viewingDuration: NSTimeInterval)
}

internal protocol PhoenixLocationProvider:class {
    
    var userLocation:PhoenixCoordinate? { get }
    
}

internal extension Phoenix {
    
    /// The Phoenix Analytics Module defines the methods available for tracking events.
    internal final class Analytics: PhoenixModule, PhoenixAnalytics {
        
        internal weak var locationProvider:PhoenixLocationProvider?
    
        /// Event queue responsible for queuing and storing events to disk.
        private var eventQueue: PhoenixEventQueue?

        internal var installation: Phoenix.Installation!
        
        // MARK:- PhoenixModuleProtocol
        
        internal init(withDelegate delegate: PhoenixInternalDelegate, network: Network, configuration: Phoenix.Configuration, installation: Installation) {
            super.init(withDelegate: delegate, network: network, configuration: configuration)
            self.installation = installation
        }
        
        override func startup(completion: (success: Bool) -> ()) {
            super.startup { [weak self] (success) -> () in
                if !success {
                    completion(success: false)
                    return
                }
                guard let this = self else {
                    completion(success: false)
                    return
                }
                this.eventQueue = PhoenixEventQueue(withCallback: this.sendEvents)
                this.eventQueue?.startQueue()
                this.trackApplicationOpened()
                completion(success: true)
            }
        }
        
        override func shutdown() {
            eventQueue?.stopQueue()
            super.shutdown()
        }
        
        @objc func track(event: Phoenix.Event) {
            eventQueue?.enqueueEvent(prepareEvent(event))
        }
        
		/// Track screen viewed event (externally managed).
		@objc func trackScreenViewed(screenName: String, viewingDuration: NSTimeInterval) {
			track(Phoenix.ScreenViewedEvent(screenName: screenName, viewingDuration: viewingDuration))
		}
		
        // MARK: Internal
        
        /// Track application open event (internally managed).
        internal func trackApplicationOpened() {
            track(Phoenix.OpenApplicationEvent())
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
            dictionary <-? (Event.ApplicationVersionKey, installation.applicationVersion.phx_applicationVersionString)
            dictionary <-? (Event.InstallationIdKey, installation.installationStorage.phx_installationID)
            dictionary <-? (Event.UserIdKey, network.oauthProvider.bestPasswordGrantOAuth.userId)
            
            // Add geolocation
            if let coordinates = locationProvider?.userLocation {
                dictionary[Event.GeolocationKey] = [
                    Event.GeolocationLatitudeKey  : coordinates.latitude,
                    Event.GeolocationLongitudeKey : coordinates.longitude
                ]
            }
            
            return dictionary
        }
        
        /// Callback from EventQueue, responsible for propogating changes to the server.
        /// - parameter events:     Array of JSONified Events to send.
        /// - parameter completion: Must be called on completion to notify caller of success/failure.
        internal func sendEvents(events: JSONDictionaryArray, completion: (error: NSError?) -> ()) {
            let operation = AnalyticsRequestOperation(json: events, oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, callback: { (returnedOperation: PhoenixOAuthOperation) -> () in
                guard let analyticsOperation = returnedOperation as? AnalyticsRequestOperation else {
                    assertionFailure("Unknown operation returned")
                    return
                }
                completion(error: analyticsOperation.output?.error)
            })
            
            network.enqueueOperation(operation)
        }
    }
}
