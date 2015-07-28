//
//  NSDataToJSON.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Alias for an array loaded from a JSON object.
public typealias JSONArray = [AnyObject]

/// Alias for a dictionary loaded from a JSON object.
public typealias JSONDictionary = [String: AnyObject]


extension NSData {
    
    /// Returns: Any object, as an optional, as returned from NSJSONSerialization.JSONObjectWithData
    private func tryJSON() -> AnyObject? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments)
        } catch let err {
            print(err)
        }
        return nil
    }
    
    /// - Returns: Array of JSONDictionary objects or nil if cast fails.
    var jsonArray: JSONArray? {
        guard let arr = tryJSON() as? JSONArray else { return nil }
        return arr
    }
    
    /// - Returns: A JSONDictionary object or nil if cast fails.
    var jsonDictionary: JSONDictionary? {
        guard let dict = tryJSON() as? JSONDictionary else { return nil }
        return dict
    }
}