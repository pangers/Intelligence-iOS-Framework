//
//  NSDataToJSON.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

extension NSData {
    typealias JSONArray = [JSONDictionary]
    typealias JSONDictionary = [String: AnyObject]
    private func tryJSON() -> AnyObject? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments)
        } catch let err {
            print(err)
        }
        return nil
    }
    var jsonArray: JSONArray? {
        guard let arr = tryJSON() as? JSONArray else { return nil }
        return arr
    }
    var jsonDictionary: JSONDictionary? {
        guard let dict = tryJSON() as? JSONDictionary else { return nil }
        return dict
    }
}