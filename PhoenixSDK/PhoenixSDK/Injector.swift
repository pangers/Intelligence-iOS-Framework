//
//  Injector.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

struct Injector {
    static internal(set) var storage:SimpleStorage = NSUserDefaults.standardUserDefaults()
}
