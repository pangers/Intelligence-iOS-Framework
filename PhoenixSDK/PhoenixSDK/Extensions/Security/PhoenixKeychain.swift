//
//  PhoenixKeychain.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class PhoenixKeychain: TSDKeychain, SimpleStorage {
    private func keyValues() -> NSMutableDictionary {
        return caughtRequest(nil, requestType: .Read) ?? NSMutableDictionary()
    }
    
    private func caughtRequest(keyValues: NSDictionary?, requestType: TSDKeychainRequestType) -> NSMutableDictionary? {
        do {
            let dictionary = try PhoenixKeychain.executeRequest(keyValues, requestType: requestType)
            return dictionary?.mutableCopy() as? NSMutableDictionary
        }
        catch let err as TSDKeychainError {
            switch err {
            case .ErrorCode(let code):
                switch code {
                case Int(errSecItemNotFound):
                    print("Item not found: \(keyValues) \(requestType.rawValue)")
                default:
                    print("Error")
                }
                
                
                print("Error: \(code)")
            case .NotFoundError:
                print("Not found error")
            }
        }
        catch {
            
        }
        return nil
    }
    
    func objectForKey(key: String) -> AnyObject? {
        let value = keyValues()[key]
        return value
    }
    
    func setObject(value: AnyObject, forKey key: String) {
        let values = keyValues()
        values[key] = value
        caughtRequest(values, requestType: .Update)
    }
    
    func removeObjectForKey(key: String) {
        let values = keyValues()
        values.removeObjectForKey(key)
        caughtRequest(values, requestType: .Update)
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
