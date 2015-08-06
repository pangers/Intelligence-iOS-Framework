//
//  PhoenixKeychain.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class PhoenixKeychain: TSDKeychain, TokenStorage {
    
    init() {
        super.init("PhoenixSDK", service: "com.tigerspike.PhoenixSDK")
    }
    
    private func keyValues() -> NSMutableDictionary {
        return executeManagedRequest(.Read)?.mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
    }
    
    private func objectForKey(key: String) -> AnyObject? {
        let value = keyValues()[key]
        return value
    }
    
    private func setObject(value: AnyObject, forKey key: String) {
        let values = keyValues()
        values[key] = value
        executeManagedRequest(.Update, keyValues: values)
    }
    
    private func removeObjectForKey(key: String) {
        let values = keyValues()
        values.removeObjectForKey(key)
        executeManagedRequest(.Update, keyValues: values)
    }
    
    func erase() {
        executeManagedRequest(.Delete)
    }
    
    // Subscript implementation
    @objc subscript(index: String) -> AnyObject? {
        get {
            // return an appropriate subscript value here
            return objectForKey(index)
        }
        set(newValue) {
            // perform a suitable setting action here
            guard let value = newValue else {
                removeObjectForKey(index)
                return
            }
            
            setObject(value, forKey: index)
        }
    }
}
