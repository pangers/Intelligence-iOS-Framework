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
    internal final class Analytics: PhoenixAnalytics {
        
        private let configuration: Configuration
        private let installation: PhoenixInstallationStorageProtocol
        private let version: PhoenixApplicationVersionProtocol
        private let network: Network
        private var eventQueue: PhoenixEventQueue?
        
        init(withNetwork network: Network, configuration: Configuration, installationStorage: PhoenixInstallationStorageProtocol, applicationVersion: PhoenixApplicationVersionProtocol) {
            self.network = network
            self.configuration = configuration
            self.installation = installationStorage
            self.version = applicationVersion
        }
        
        func startup() {
            eventQueue = PhoenixEventQueue(withCallback: sendEvents)
            eventQueue?.startQueue()
        }
        
        func shutdown() {
            eventQueue?.stopQueue()
        }
        
        private func sendEvents(items: JSONDictionaryArray, completion: (Bool) -> ()) {
            // TODO: Create network URLRequest, etc
            // TODO: Call completion on success/failure
            completion(false)
        }
        
        @objc func track(event: Phoenix.Event) {
            eventQueue?.enqueueEvent(prepareEvent(event))
        }
        
        func prepareEvent(event: Event) -> JSONDictionary {
            var dictionary = event.toJSON()

            // FIXME: Are these fields correct? Using postman example...
            dictionary[Event.ApplicationIdKey] = configuration.applicationID
            dictionary[Event.DeviceTypeKey] = UIDevice.currentDevice().model
            dictionary[Event.OperationSystemVersionKey] = UIDevice.currentDevice().systemVersion
            
            // Set optional values (may fail for whatever reason).
            dictionary <-? (Event.ApplicationVersionKey, version.phx_applicationVersionString)
            dictionary <-? (Event.InstallationIdKey, installation.phx_installationID)
            
            // TODO: UserId
            
            return dictionary
        }
    }
    
}
