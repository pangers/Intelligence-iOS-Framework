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
        if value == nil {
            removeObjectForKey(key)
        } else {
            // Treat empty values the same as nil
            if let str = value as? String where str.isEmpty {
                removeObjectForKey(key)
            } else {
                setObject(value, forKey: key)
            }
        }
        synchronize()
    }
    func pd_get(key: String) -> AnyObject? {
        return valueForKey(key)
    }
}