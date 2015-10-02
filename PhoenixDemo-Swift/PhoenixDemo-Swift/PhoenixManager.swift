//
//  PhoenixManager.swift
//  PhoenixDemo-Swift
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import PhoenixSDK

class PhoenixManager {
    
    internal private(set) static var phoenix:Phoenix?
        
    static func startupWithPhoenix(phoenix:Phoenix) {
        PhoenixManager.phoenix = phoenix
    }
}