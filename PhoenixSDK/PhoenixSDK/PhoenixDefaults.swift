//
//  PhoenixDefaults.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 28/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

let phoenixDefaults = PhoenixDefaults.phoenixDefaults()

class PhoenixDefaults: NSUserDefaults {
    class func phoenixDefaults() -> PhoenixDefaults {
        return PhoenixDefaults(suiteName: "PhoenixSDK")!
    }
    func pd_set(value: AnyObject?, forKey key: String) {
        if value == nil || (value is String && (value as! String).isEmpty) {
            removeObjectForKey(key)
        } else {
            setObject(value, forKey: key)
        }
        synchronize()
    }
    func pd_get(key: String) -> AnyObject? {
        return valueForKey(key)
    }
}