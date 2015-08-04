//
//  PhoenixModules.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// PhoenixModuleProtocol defines a protocol that all modules should adhere to.
@objc public protocol PhoenixModule {
    
    /// Initializes the module. Requires to be called before using the module.
    func startup()
    
}
