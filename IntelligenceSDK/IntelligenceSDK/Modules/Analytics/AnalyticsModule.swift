//
//  AnalyticsModule.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 18/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import UIKit

/// The Intelligence Analytics Module defines the methods available for tracking events.
@objc (INTAnalyticsModuleProtocol)
public protocol AnalyticsModuleProtocol : ModuleProtocol {
    
    /// Pause analytics module, must be called when entering the background.
    func pause()
    
    /// Resume analytics module, must be called after returning from background.
    func resume()
    
    /// Track user engagement and behavioral insight.
    /// - parameter event: Event containing information to track.
    func track(event: Event)
}

internal protocol LocationModuleProvider:class {
    
    var userLocation:Coordinate? { get }
    
}

/// The Intelligence Analytics Module defines the methods available for tracking events.
internal final class AnalyticsModule: IntelligenceModule, AnalyticsModuleProtocol {

    internal weak var locationProvider: LocationModuleProvider?

    /// Event queue responsible for queuing and storing events to disk.
    internal var eventQueue: EventQueue?
    internal var timeTracker: TimeTracker?
    
    internal var installation: Installation!
    
    
    // MARK:- ModuleProtocol
    
    internal init(withDelegate delegate: IntelligenceInternalDelegate, network: Network, configuration: Intelligence.Configuration, installation: Installation) {
        super.init(withDelegate: delegate, network: network, configuration: configuration)
        self.installation = installation
    }
    
    
    override func startup(completion: @escaping (Bool) -> ()) {
        super.startup { [weak self] (success) -> () in
            if !success {
                completion(false)
                return
            }
            guard let this = self else {
                completion(false)
                return
            }
            this.eventQueue = EventQueue(withCallback: this.sendEvents)
            this.eventQueue?.startQueue()
            
            this.track(event: OpenApplicationEvent(applicationID: this.configuration.applicationID))
            
            this.timeTracker = TimeTracker(storage: TimeTrackerStorage(userDefaults: UserDefaults.standard), callback: { [weak self] (event) -> () in
                self?.track(event: event)
            })
            completion(true)
        }
    }
    
    func pause() {
        eventQueue?.stopQueue()
        timeTracker?.pause()
    }
    
    func resume() {
        eventQueue?.startQueue()
        timeTracker?.resume()
    }
    
    override func shutdown() {
        eventQueue?.stopQueue()
        timeTracker = nil
        super.shutdown()
    }
    
    func track(event: Event) {
        eventQueue?.enqueueEvent(event: prepareEvent(event: event))
    }
    
    // MARK: Internal
    
    /// Add automatically populated fields to dictionary.
    /// - parameter event: Event to prepare for sending.
    /// - returns: JSONDictionary representation of Event including populated fields.
    internal func prepareEvent(event: Event) -> JSONDictionary {
        var dictionary = event.toJSON()
        
        dictionary[Event.ProjectIdKey] = configuration.projectID
        dictionary[Event.ApplicationIdKey] = configuration.applicationID
        dictionary[Event.DeviceTypeKey] = UIDevice.current.model
        dictionary[Event.OperationSystemVersionKey] = UIDevice.current.systemVersion
        
        // Set optional values (may fail for whatever reason).
        dictionary <-? (Event.ApplicationVersionKey, installation.applicationVersion.int_applicationVersionString)
        dictionary <-? (Event.InstallationIdKey, installation.installationStorage.int_installationID)
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
    internal func sendEvents(events: JSONDictionaryArray, completion: @escaping (NSError?) -> ()) {
        let operation = AnalyticsRequestOperation(json: events, oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
            let analyticsOperation = returnedOperation as! AnalyticsRequestOperation
            completion(analyticsOperation.output?.error)
        })
        
        network.enqueueOperation(operation: operation)
    }
}
