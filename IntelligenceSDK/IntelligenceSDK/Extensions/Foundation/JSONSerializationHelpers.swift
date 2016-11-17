//
//  NSJSONSerializationHelpers.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Alias for an array loaded from a JSON object.
internal typealias JSONArray = [Any]

/// Alias for an array of dictionaries loaded from a JSON object.
internal typealias JSONDictionaryArray = [JSONDictionary]

/// Alias for a dictionary loaded from a JSON object.
internal typealias JSONDictionary = [String: Any]

/// Optionally set a value for a specific key and dictionary.
/// - parameter key:        Key to set.
/// - parameter value:      Value to set, optionally.
/// - parameter dictionary: JSONDictionary to use.
internal func setOptionalValue(value: Any?, forKey key: String, inDictionary dictionary: inout [String: Any]) {
    guard let value = value else { return }
    dictionary[key] = value
}

precedencegroup SetOptional {
     associativity: right
}

infix operator <-? : SetOptional

/// Optionally set a value for a specific key in a dictionary. 
/// Operator for setOptionalValue method.
/// - parameter lhs: JSONDictionary to use.
/// - parameter rhs: Key, Value? tuple.
internal func <-? (lhs: inout JSONDictionary, rhs: (String, Any?)) {
    setOptionalValue(value: rhs.1, forKey: rhs.0, inDictionary: &lhs)
}

internal extension Data {
    
    /// Returns: Any object, as an optional, as returned from NSJSONSerialization.JSONObjectWithData
    private func int_tryJSON() -> Any? {
//        return try? JSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments)
        return try? JSONSerialization.jsonObject(with: self, options: .allowFragments)
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
    func int_toJSONData() -> Data? {
        if JSONSerialization.isValidJSONObject(self) {
            return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        }
        return nil
    }
}

internal extension Collection {
    
    /// Converts a JSON Array to NSData. Accepts any Collection type, not just the JSONArray/JSONDictionaryArray we defined.
    /// - Returns: nil or NSData representation of JSON Object.
    func int_toJSONData() -> Data? {
        if JSONSerialization.isValidJSONObject(self) {
            return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        }
        return nil
    }
}
