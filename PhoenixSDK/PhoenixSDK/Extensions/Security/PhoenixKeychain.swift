//
//  PhoenixKeychain.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class PhoenixKeychain: TSDKeychain, SimpleStorage {
    
    init() {
        super.init("PhoenixSDK", service: "com.tigerspike.PhoenixSDK")
    }
    
    private func keyValues() -> NSMutableDictionary {
        return executeManagedRequest(.Read)?.mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
    }
    
    func objectForKey(key: String) -> AnyObject? {
        let value = keyValues()[key]
        return value
    }
    
    func setObject(value: AnyObject, forKey key: String) {
        let values = keyValues()
        values[key] = value
        executeManagedRequest(.Update, keyValues: values)
    }
    
    func removeObjectForKey(key: String) {
        let values = keyValues()
        values.removeObjectForKey(key)
        executeManagedRequest(.Update, keyValues: values)
    }
    
    // Subscript implementation
    subscript(index: String) -> AnyObject? {
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
