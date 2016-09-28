//
//  NSJSONSerializationHelpers.swift
//  IntelligenceSDK
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

/// Optionally set a value for a specific key and dictionary.
/// - parameter key:        Key to set.
/// - parameter value:      Value to set, optionally.
/// - parameter dictionary: JSONDictionary to use.
internal func setOptionalValue(value: AnyObject?, forKey key: String, inout inDictionary dictionary: [String: AnyObject]) {
    guard let value = value else { return }
    dictionary[key] = value
}

infix operator <-? { associativity right precedence 60 }

/// Optionally set a value for a specific key in a dictionary. 
/// Operator for setOptionalValue method.
/// - parameter lhs: JSONDictionary to use.
/// - parameter rhs: Key, Value? tuple.
internal func <-? (inout lhs: JSONDictionary, rhs: (String, AnyObject?)) {
    setOptionalValue(rhs.1, forKey: rhs.0, inDictionary: &lhs)
}

internal extension NSData {
    
    /// Returns: Any object, as an optional, as returned from NSJSONSerialization.JSONObjectWithData
    private func int_tryJSON() -> AnyObject? {
        return try? NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments)
    }
    
    /// - Returns: Array of AnyObjects or nil if cast fails.
    var int_jsonArray: JSONArray? {
        guard let arr = int_tryJSON() as? JSONArray else { return nil }
        return arr
    }
    
    /// - Returns: Array of JSONDictionary objects or nil if cast fails.
    var int_jsonDictionaryArray: JSONDictionaryArray? {
        guard let arr = int_tryJSON() as? JSONDictionaryArray else { return nil }
        return arr
    }
    
    /// - Returns: A JSONDictionary object or nil if cast fails.
    var int_jsonDictionary: JSONDictionary? {
        guard let dict = int_tryJSON() as? JSONDictionary else { return nil }
        return dict
    }
}

internal extension Dictionary {
    /// Converts a JSON Dictionary to NSData. Accepts any Dictionary type, not just the JSONDictionary we defined.
    /// - Returns: nil or NSData representation of JSON Object.
    func int_toJSONData() -> NSData? {
        if let anyObject = self as? AnyObject where NSJSONSerialization.isValidJSONObject(anyObject) {
            return try? NSJSONSerialization.dataWithJSONObject(anyObject, options: .PrettyPrinted)
        }
        return nil
    }
}

internal extension CollectionType {
    
    /// Converts a JSON Array to NSData. Accepts any Collection type, not just the JSONArray/JSONDictionaryArray we defined.
    /// - Returns: nil or NSData representation of JSON Object.
    func int_toJSONData() -> NSData? {
        if let anyObject = self as? AnyObject where NSJSONSerialization.isValidJSONObject(anyObject) {
            return try? NSJSONSerialization.dataWithJSONObject(anyObject, options: .PrettyPrinted)
        }
        return nil
    }
}