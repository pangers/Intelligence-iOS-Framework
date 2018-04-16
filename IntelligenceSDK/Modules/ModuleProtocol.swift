//
//  ModuleProtocol.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

@objc public protocol ModuleProtocol {

    func startup(completion: @escaping (_ success: Bool) -> Void)

    func shutdown()

}

class IntelligenceModule: NSObject, ModuleProtocol {

    var delegate: IntelligenceInternalDelegate!

    /// A reference to the Network manager.
    let network: Network

    /// Configuration instance used for NSURLRequests.
    let configuration: Intelligence.Configuration

    /// Default initializer. Requires a network and configuration class and a geofence enter/exit callback.
    /// - parameter delegate:         Delegate used to notify developer of an event.
    /// - parameter network:          Instance of Network class to use.
    /// - parameter configuration:    Configuration used to configure requests.
    /// - returns: An initialized module.
    init(withDelegate delegate: IntelligenceInternalDelegate, network: Network, configuration: Intelligence.Configuration) {
        self.delegate = delegate
        self.network = network
        self.configuration = configuration
        super.init()
    }

    /// Initialise this module, called for each module on SDK startup.
    func startup(completion: @escaping (_ success: Bool) -> Void) {
        completion(true)
    }

    /// Terminate this module. Must call startup in order to resume, should only occur on SDK shutdown.
    func shutdown() {

    }
}
