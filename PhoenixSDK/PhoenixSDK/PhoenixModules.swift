//
//  PhoenixModules.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// PhoenixModuleProtocol defines a protocol that all modules should adhere to.
public protocol PhoenixModuleProtocol {
    
    /// Initializes the module. Requires to be called before using the module.
    func startup()
    
}

/// PhoenixModule base class. Used to assure that startup was called.
///
/// When overriding it, startup should always be called.
class PhoenixModule : PhoenixModuleProtocol {

    /// Boolean to specify if the startup was called before using
    /// the module.
    var didStartup:Bool = false
    
    /// Initializes the module.
    func startup() {
        self.didStartup = true
    }
    
}
