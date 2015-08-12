//
//  NSJSONSerializationHelpers.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Alias for an array loaded from a JSON object.
internal typealias JSONArray = [AnyObject]

/// Alias for an array of dictionaries loaded from a JSON object.
internal typealias JSONDictionaryArray = [JSONDictionary]

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
    
    /// - Returns: Array of AnyObjects or nil if cast fails.
    var phx_jsonArray: JSONArray? {
        guard let arr = phx_tryJSON() as? JSONArray else { return nil }
        return arr
    }
    
    /// - Returns: Array of JSONDictionary objects or nil if cast fails.
    var phx_jsonDictionaryArray: JSONDictionaryArray? {
        guard let arr = phx_tryJSON() as? JSONDictionaryArray else { return nil }
        return arr
    }
    
    /// - Returns: A JSONDictionary object or nil if cast fails.
    var phx_jsonDictionary: JSONDictionary? {
        guard let dict = phx_tryJSON() as? JSONDictionary else { return nil }
        return dict
    }
}

internal extension Dictionary {
    
    /// Converts a JSON Dictionary to NSData. Accepts any Dictionary type, not just the JSONDictionary we defined.
    /// - Returns: nil or NSData representation of JSON Object.
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

internal extension CollectionType {
    
    /// Converts a JSON Array to NSData. Accepts any Collection type, not just the JSONArray/JSONDictionaryArray we defined.
    /// - Returns: nil or NSData representation of JSON Object.
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