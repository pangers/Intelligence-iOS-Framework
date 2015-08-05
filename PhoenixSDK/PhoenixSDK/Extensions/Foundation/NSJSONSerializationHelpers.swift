//
//  NSJSONSerializationHelpers.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

infix operator ?+=  { associativity right precedence 90 }

/// Create operator to optionally add a key-value to a Dictionary using a Tuple.
/// Usage: JSONDictionary ?+= (key, nil) | fails
/// Usage: JSONDictionary ?+= (key, "Test") | succeeds
func ?+= (inout lhs: JSONDictionary, rhs: (String, AnyObject?)) {
    if let value = rhs.1 {
        lhs[rhs.0] = value
    }
}

/// Alias for an array loaded from a JSON object.
internal typealias JSONArray = [AnyObject]

/// Alias for a dictionary loaded from a JSON object.
internal typealias JSONDictionary = [String: AnyObject]

internal extension NSData {
    
    /// Returns: Any object, as an optional, as returned from NSJSONSerialization.JSONObjectWithData
    private func phx_tryJSON() -> AnyObject? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments)
        } catch let err {
            print(err)
        }
        return nil
    }
    
    /// - Returns: Array of JSONDictionary objects or nil if cast fails.
    var phx_jsonArray: JSONArray? {
        guard let arr = phx_tryJSON() as? JSONArray else { return nil }
        return arr
    }
    
    /// - Returns: A JSONDictionary object or nil if cast fails.
    var phx_jsonDictionary: JSONDictionary? {
        guard let dict = phx_tryJSON() as? JSONDictionary else { return nil }
        return dict
    }
}

extension Dictionary {
    func phx_toJSONData() -> NSData? {
        if let anyObject = self as? AnyObject {
            do {
                return try NSJSONSerialization.dataWithJSONObject(anyObject, options: .PrettyPrinted)
            } catch {
            }
        }
        return nil
    }
}

extension CollectionType {
    func phx_toJSONData() -> NSData? {
        if let anyObject = self as? AnyObject {
            do {
                return try NSJSONSerialization.dataWithJSONObject(anyObject, options: .PrettyPrinted)
            } catch {
            }
        }
        return nil
    }
}