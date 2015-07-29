//
//  NSDataToJSON.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

extension NSData {
    
    /// Returns: Any object, as an optional, as returned from NSJSONSerialization.JSONObjectWithData
    private func pd_tryJSON() -> AnyObject? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments)
        } catch let err {
            print(err)
        }
        return nil
    }
    
    /// - Returns: Array of JSONDictionary objects or nil if cast fails.
    var pd_jsonArray: JSONArray? {
        guard let arr = pd_tryJSON() as? JSONArray else { return nil }
        return arr
    }
    
    /// - Returns: A JSONDictionary object or nil if cast fails.
    var pd_jsonDictionary: JSONDictionary? {
        guard let dict = pd_tryJSON() as? JSONDictionary else { return nil }
        return dict
    }
}