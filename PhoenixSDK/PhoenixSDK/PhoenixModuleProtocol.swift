//
//  PhoenixModuleProtocol.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal protocol PhoenixModuleProtocol {
    /// Initialise this module, called for each module on SDK startup.
    func startup()
    /// Terminate this module. Must call startup in order to resume, should only occur on SDK shutdown.
    func shutdown()
}