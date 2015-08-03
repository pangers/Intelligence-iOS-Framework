//
//  Injector.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// A naive injector object.
/// Uses lazy vars in order to allow to inject a different object in it.
/// Currently holds:
/// - SimpleStorage: Used to keep the authentication tokens.
internal struct Injector {
    static internal(set) var storage:SimpleStorage = TSDKeychain() //   NSUserDefaults.standardUserDefaults()
}
