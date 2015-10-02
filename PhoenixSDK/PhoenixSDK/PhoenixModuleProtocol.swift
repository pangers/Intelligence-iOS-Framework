//
//  PhoenixModuleProtocol.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

@objc public protocol PhoenixModuleProtocol {
    
    func startup()
    
    func shutdown()
    
}

internal class PhoenixModule : NSObject,PhoenixModuleProtocol {
    
    /// A reference to the Network manager.
    internal let network: Network
    
    /// Configuration instance used for NSURLRequests.
    internal let configuration: Phoenix.Configuration
    
    /// Default initializer. Requires a network and configuration class and a geofence enter/exit callback.
    /// - parameter network:          Instance of Network class to use.
    /// - parameter configuration:    Configuration used to configure requests.
    /// - returns: An initialized module.
    internal init(withNetwork network: Network, configuration: Phoenix.Configuration) {
        self.network = network
        self.configuration = configuration
        super.init()
    }
    
    /// Initialise this module, called for each module on SDK startup.
    func startup() {
        
    }
    
    /// Terminate this module. Must call startup in order to resume, should only occur on SDK shutdown.
    func shutdown() {
        
    }
}