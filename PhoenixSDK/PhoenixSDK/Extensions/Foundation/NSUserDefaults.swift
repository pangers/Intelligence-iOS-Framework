//
//  File.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 28/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal extension NSUserDefaults : SimpleStorage {
    
    // Subscript implementation
    subscript(index: String) -> AnyObject? {
        get {
            // return an appropriate subscript value here
            return objectForKey(index)
        }
        set(newValue) {
            defer {
                synchronize()
            }
            
            // perform a suitable setting action here
            guard let value = newValue else {
                removeObjectForKey(index)
                return
            }
            
            setObject(value, forKey: index)
        }
    }
}