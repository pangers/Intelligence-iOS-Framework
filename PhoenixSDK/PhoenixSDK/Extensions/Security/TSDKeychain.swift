//
//  TSDKeychain.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import Locksmith

class TSDKeychain: SimpleStorage {
    private let PhoenixUser = "PhoenixSDK"
    
    private func keyValues() -> NSMutableDictionary {
        let (dictionary, _) = Locksmith.loadDataForUserAccount(PhoenixUser)
        return dictionary?.mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
    }
    
    func objectForKey(key: String) -> AnyObject? {
        return keyValues()[key]
    }
    
    func setObject(value: AnyObject, forKey key: String) {
        let values = keyValues()
        values[key] = value.description!
        Locksmith.updateData(values.copy() as! Dictionary<String, String>, forUserAccount: PhoenixUser)
    }
    
    func removeObjectForKey(key: String) {
        let values = keyValues()
        values.removeObjectForKey(key)
        Locksmith.updateData(values.copy() as! Dictionary<String, String>, forUserAccount: PhoenixUser)
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
