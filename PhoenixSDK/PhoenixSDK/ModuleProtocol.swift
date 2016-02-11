//
//  ModuleProtocol.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

@objc public protocol ModuleProtocol {
    
    func startup(completion: (success: Bool) -> ())
    
    func shutdown()
    
}

internal class IntelligenceModule : NSObject, ModuleProtocol {
    
    internal var delegate: IntelligenceInternalDelegate!
    
    /// A reference to the Network manager.
    internal let network: Network
    
    /// Configuration instance used for NSURLRequests.
    internal let configuration: Intelligence.Configuration
    
    /// Default initializer. Requires a network and configuration class and a geofence enter/exit callback.
    /// - parameter delegate:         Delegate used to notify developer of an event.
    /// - parameter network:          Instance of Network class to use.
    /// - parameter configuration:    Configuration used to configure requests.
    /// - returns: An initialized module.
    internal init(withDelegate delegate: IntelligenceInternalDelegate, network: Network, configuration: Intelligence.Configuration) {
        self.delegate = delegate
        self.network = network
        self.configuration = configuration
        super.init()
    }
    
    /// Initialise this module, called for each module on SDK startup.
    func startup(completion: (success: Bool) -> ()) {
        completion(success: true)
    }
    
    /// Terminate this module. Must call startup in order to resume, should only occur on SDK shutdown.
    func shutdown() {
        
    }
}